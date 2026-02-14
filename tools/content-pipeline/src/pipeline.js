/**
 * StudyReps Content Pipeline - Main Orchestrator
 * 
 * Automates the entire content creation process:
 * 1. Generate educational script from topic content (Gemini)
 * 2. Convert script to audio (Google TTS / ElevenLabs)
 * 3. Generate video from audio (FFmpeg)
 * 4. Upload to Supabase Storage
 * 5. Output video URL for app integration
 */

import 'dotenv/config';
import { Command } from 'commander';
import chalk from 'chalk';
import ora from 'ora';
import { generateScript } from './gemini-script.js';
import { generateAudio } from './audio-generator.js';
import { generateVideo } from './video-generator.js';
import { uploadToSupabase } from './uploader.js';

const program = new Command();

program
  .name('studyreps-pipeline')
  .description('Automated content generation for StudyReps')
  .version('1.0.0');

program
  .command('generate')
  .description('Generate a complete video from topic content')
  .requiredOption('-t, --topic <title>', 'Topic title')
  .requiredOption('-c, --content <text>', 'Topic content/concepts')
  .option('-d, --difficulty <level>', 'Difficulty level (1-3)', '1')
  .option('-q, --question <json>', 'Question JSON for The Lock')
  .option('-o, --output <path>', 'Output directory', './output')
  .action(async (options) => {
    console.log(chalk.blue.bold('\n🚀 StudyReps Content Pipeline\n'));
    
    try {
      // Step 1: Generate Script
      const spinner1 = ora('Generating educational script with Gemini...').start();
      const script = await generateScript({
        topic: options.topic,
        content: options.content,
        difficulty: parseInt(options.difficulty),
      });
      spinner1.succeed(chalk.green('Script generated!'));
      console.log(chalk.gray(`   Script length: ${script.length} characters`));
      
      // Step 2: Generate Audio
      const spinner2 = ora('Converting script to audio...').start();
      const audioPath = await generateAudio({
        script,
        outputDir: options.output,
        filename: `${sanitizeFilename(options.topic)}.mp3`,
      });
      spinner2.succeed(chalk.green('Audio generated!'));
      console.log(chalk.gray(`   Audio saved to: ${audioPath}`));
      
      // Step 3: Generate Video
      const spinner3 = ora('Generating video from audio...').start();
      const videoPath = await generateVideo({
        audioPath,
        topic: options.topic,
        outputDir: options.output,
        filename: `${sanitizeFilename(options.topic)}.mp4`,
      });
      spinner3.succeed(chalk.green('Video generated!'));
      console.log(chalk.gray(`   Video saved to: ${videoPath}`));
      
      // Step 4: Upload to Supabase
      const spinner4 = ora('Uploading to Supabase Storage...').start();
      const videoUrl = await uploadToSupabase({
        filePath: videoPath,
        bucket: 'studyreps-videos',
        path: `physics/force/${sanitizeFilename(options.topic)}.mp4`,
      });
      spinner4.succeed(chalk.green('Uploaded to Supabase!'));
      
      // Output results
      console.log(chalk.blue.bold('\n✅ Content Generated Successfully!\n'));
      console.log(chalk.white('Video URL:'));
      console.log(chalk.cyan(videoUrl));
      console.log();
      
      // Output VideoModel snippet
      console.log(chalk.white('Add to video_feed_provider.dart:'));
      console.log(chalk.yellow(`
VideoModel(
  id: '${sanitizeFilename(options.topic)}',
  videoUrl: '${videoUrl}',
  lockTimestamp: 45,
  question: QuestionModel(
    id: 'q_${sanitizeFilename(options.topic)}',
    prompt: '${options.question || 'Add your question here'}',
    correctAnswer: 'your_answer',
    type: QuestionType.multipleChoice,
  ),
  creatorName: 'StudyReps AI',
  creatorAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AI',
  title: '${options.topic}',
  subject: 'Physics',
),
`));
      
    } catch (error) {
      console.error(chalk.red('\n❌ Pipeline failed:'), error.message);
      process.exit(1);
    }
  });

program
  .command('batch')
  .description('Generate videos for multiple topics from config file')
  .requiredOption('-c, --config <path>', 'Path to topics config JSON')
  .option('-o, --output <path>', 'Output directory', './output')
  .action(async (options) => {
    const fs = await import('fs');
    const config = JSON.parse(fs.readFileSync(options.config, 'utf8'));
    
    console.log(chalk.blue.bold(`\n🚀 Batch Processing ${config.topics.length} Topics\n`));
    
    for (let i = 0; i < config.topics.length; i++) {
      const topic = config.topics[i];
      console.log(chalk.white(`\n[${i + 1}/${config.topics.length}] Processing: ${topic.title}`));
      
      try {
        // Run pipeline for each topic
        const script = await generateScript({
          topic: topic.title,
          content: topic.content,
          difficulty: topic.difficulty || 1,
        });
        
        const audioPath = await generateAudio({
          script,
          outputDir: options.output,
          filename: `${topic.id}.mp3`,
        });
        
        const videoPath = await generateVideo({
          audioPath,
          topic: topic.title,
          outputDir: options.output,
          filename: `${topic.id}.mp4`,
        });
        
        const videoUrl = await uploadToSupabase({
          filePath: videoPath,
          bucket: 'studyreps-videos',
          path: `${config.subject}/${config.chapter}/${topic.id}.mp4`,
        });
        
        console.log(chalk.green(`   ✅ Done! URL: ${videoUrl}`));
        
      } catch (error) {
        console.error(chalk.red(`   ❌ Failed: ${error.message}`));
      }
    }
    
    console.log(chalk.blue.bold('\n🎉 Batch processing complete!\n'));
  });

function sanitizeFilename(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '');
}

program.parse();
