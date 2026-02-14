/**
 * Visual Generator (Generic/SVG)
 * 
 * Generates educational visuals using Gemini (Text-to-SVG)
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { GoogleGenerativeAI } from '@google/generative-ai';
import sharp from 'sharp';

// Initialize Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

/**
 * Generate visuals for a script
 * @returns {Promise<string[]>} Array of image file paths
 */
export async function generateVisuals({
    script,
    topic,
    outputDir,
    prefix = 'viz'
}) {
    console.log('🎨 Requesting visual concepts from Gemini...');

    // 1. Plan Scenes
    // We want 3-5 scenes for a 90s video
    const prompt = `
    You are an educational illustrator.
    Analyze this physics script and create 4 distinct visual concepts (SVGs) that illustrate the key points.
    
    Script: "${script.substring(0, 1000)}..."
    
    For each scene, generate a valid, standalone SVG code string.
    The SVGs should be:
    - 9:16 aspect ratio (1080x1920 viewbox) or adaptable
    - Minimalist flat design
    - Dark mode compatible (background #0F172A)
    - Use bright accents (#6366F1, #F43F5E, #10B981)
    - Educational and clear (diagrams, labels, formulas)
    
    Return output as JSON:
    [
      { "description": "Scene description", "svg": "<svg...>...</svg>" },
      ...
    ]
    RETURN JSON ONLY. No markdown formatting.
    `;

    try {
        const result = await model.generateContent(prompt);
        const response = result.response;
        let text = response.text();

        // Clean markdown code blocks if present
        text = text.replace(/```json/g, '').replace(/```/g, '').trim();

        const scenes = JSON.parse(text);
        const imagePaths = [];

        console.log(`🎨 Generating ${scenes.length} SVGs...`);

        for (let i = 0; i < scenes.length; i++) {
            const scene = scenes[i];
            const svgContent = scene.svg;

            // Ensure background rect exists if missing
            let finalSvg = svgContent;
            if (!svgContent.includes('<rect width="100%" height="100%" fill="#0F172A"')) {
                // Determine viewbox
                const viewboxMatch = svgContent.match(/viewBox="([^"]*)"/);
                let w = 1080, h = 1920;
                if (viewboxMatch) {
                    const parts = viewboxMatch[1].split(/[ ,]/).filter(x => x);
                    if (parts.length === 4) { w = parts[2]; h = parts[3]; }
                }
                // Inject BG rect
                const bgRect = `<rect width="100%" height="100%" fill="#0F172A" />`;
                finalSvg = finalSvg.replace(/>/, `>${bgRect}`);
            }

            const svgPath = path.join(outputDir, `${prefix}_${i}.svg`);
            const pngPath = path.join(outputDir, `${prefix}_${i}.png`);

            // Save SVG
            fs.writeFileSync(svgPath, finalSvg);

            // Convert to PNG using Sharp
            await sharp(Buffer.from(finalSvg))
                .resize(1080, 1920, { fit: 'contain', background: { r: 15, g: 23, b: 42, alpha: 1 } })
                .png()
                .toFile(pngPath);

            imagePaths.push(pngPath);
            console.log(`  ✓ Created ${path.basename(pngPath)}: ${scene.description.substring(0, 30)}...`);
        }

        return imagePaths;

    } catch (error) {
        console.warn(`⚠️ Visual generation failed: ${error.message}`);
        // Return empty array to trigger fallback (or use a default)
        return [];
    }
}
