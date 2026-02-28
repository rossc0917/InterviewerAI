"""InterviewerAI - Server-Side Data Layer."""

import os;
import tempfile;
import base64;
import time;  # <--- NEW: Needed for our waiting loop
import google.generativeai as genai;

walker:priv SubmitInterview {
    has role: str;
    has question: str;
    has video_b64: str;

    can process with Root entry {
        # 1. Grab the API key from your environment
        api_key = os.environ.get("GEMINI_API_KEY");
        if not api_key {
            report {"error": "GEMINI_API_KEY is missing. Please set it in your terminal before running jac start."};
            return;
        }

        genai.configure(api_key=api_key);

        try {
            # 2. Extract the raw video data from the base64 string
            encoded_data = self.video_b64.split(",")[1];
            video_data = base64.b64decode(encoded_data);

            # 3. Save it to a temporary file
            temp_file_path = "";
            with tempfile.NamedTemporaryFile(delete=False, suffix=".webm") as temp_video {
                temp_video.write(video_data);
                temp_file_path = temp_video.name;
            }

            # 4. Upload to the Gemini File API
            video_file = genai.upload_file(path=temp_file_path);

            # 5. WAIT FOR PROCESSING (The Magic Fix)
            # Gemini needs time to extract frames and audio before the LLM can see it.
            while video_file.state.name == "PROCESSING" {
                time.sleep(2);
                video_file = genai.get_file(video_file.name);
            }
            
            # Catch corrupted uploads
            if video_file.state.name == "FAILED" {
                report {"error": "Gemini failed to process the uploaded video."};
                os.remove(temp_file_path);
                return;
            }

            # 6. Prompt Gemini 1.5 Pro
            model = genai.GenerativeModel("gemini-1.5-pro");
            prompt = (
                "You are an expert interview coach. " +
                "The candidate is applying for the role of: " + self.role + ". " +
                "They were asked this question: " + self.question + ". " +
                "Review the attached video response. Evaluate their communication skills, " +
                "clarity, and the technical accuracy of their answer. " +
                "Provide highly actionable, constructive feedback in a clean, readable format."
            );

            response = model.generate_content([prompt, video_file]);

            # 7. Clean up the temp file
            os.remove(temp_file_path);

            # 8. Send the AI's advice back to the frontend
            report {"success": True, "feedback": response.text};

        } except Exception as e {
            report {"error": "Backend Error: " + str(e)};
        }
    }
}