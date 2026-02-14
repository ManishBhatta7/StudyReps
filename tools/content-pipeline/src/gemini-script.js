/**
 * Gemini Script Generator
 * 
 * Uses Google's Gemini API to generate educational scripts
 * from topic content. The script is optimized for:
 * - 90-120 second audio duration
 * - Conversational, engaging tone
 * - Key concept emphasis
 * - Real-world examples
 */

import 'dotenv/config';
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * Generate an educational script for a topic
 * @param {Object} options - Script generation options
 * @param {string} options.topic - Topic title
 * @param {string} options.content - Key concepts and content
 * @param {number} options.difficulty - Difficulty level (1-3)
 * @returns {Promise<string>} - Generated script text
 */
export async function generateScript({ topic, content, difficulty = 1 }) {
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const difficultyGuide = {
        1: 'Use simple language, more examples, slower pace. Target: Class 8-9 students.',
        2: 'Balanced technical terms and examples. Target: Class 10 students.',
        3: 'More technical, fewer basic explanations. Target: Class 11-12 students.',
    };

    const prompt = `You are an expert educational content creator. Generate a script for a short educational video.

TOPIC: ${topic}

CONTENT TO COVER:
${content}

REQUIREMENTS:
- Duration: 90-120 seconds when spoken (approximately 200-280 words)
- Style: Conversational, like a friendly tutor explaining to a student
- Tone: Enthusiastic but not cheesy
- ${difficultyGuide[difficulty] || difficultyGuide[1]}

STRUCTURE:
1. Hook (10 sec): Start with an interesting question or fact
2. Core Explanation (60-80 sec): Explain the main concept clearly
3. Example (20-30 sec): Give a real-world example
4. Summary (10 sec): Quick recap of the key point

FORMATTING RULES:
- Write as plain spoken text (no stage directions)
- Don't include "[pause]" or timing markers
- Don't include "Host:" or speaker labels
- Use natural speech patterns
- Include emphasis for important terms (they'll be highlighted in video)

Generate the script now:`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    return response.text().trim();
}

/**
 * Generate a question for "The Lock" from topic content
 * @param {Object} options - Question generation options
 * @returns {Promise<Object>} - Question object
 */
export async function generateQuestion({ topic, content, format = 'multiple_choice' }) {
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const formatGuide = {
        multiple_choice: 'Create a multiple choice question with 4 options (A, B, C, D)',
        numerical: 'Create a numerical calculation question',
        true_false: 'Create a True/False statement',
        fill_blank: 'Create a fill-in-the-blank sentence',
    };

    const prompt = `Generate a quiz question for the following educational topic.

TOPIC: ${topic}

CONTENT:
${content}

FORMAT: ${formatGuide[format]}

OUTPUT AS JSON:
{
  "prompt": "The question text",
  "options": ["A", "B", "C", "D"],  // only for multiple_choice
  "correctAnswer": "The correct answer",
  "hint": "A helpful hint",
  "explanation": "Why this is the correct answer"
}

Generate the question JSON:`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text().trim();

    // Extract JSON from response
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
    }
    throw new Error('Failed to parse question JSON from Gemini response');
}

// Test function
if (process.argv.includes('--test')) {
    console.log('Testing Gemini Script Generator...\n');

    const testTopic = "Newton's First Law of Motion";
    const testContent = `
    - A body continues in rest or uniform motion unless external force acts
    - Also called Law of Inertia
    - Examples: passenger in bus, tablecloth trick
  `;

    try {
        const script = await generateScript({
            topic: testTopic,
            content: testContent,
            difficulty: 2,
        });

        console.log('Generated Script:\n');
        console.log(script);
        console.log(`\nWord count: ${script.split(/\s+/).length}`);

    } catch (error) {
        console.error('Test failed:', error.message);
    }
}
