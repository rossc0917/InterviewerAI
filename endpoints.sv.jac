"""InterviewerAI - Server-Side Data Layer."""

import os;
import tempfile;
import base64;
import time;
import google.genai as genai;

walker:pub SubmitInterview {
    has role: str;
    has question: str;
    has video_b64: str;

    can process with Root entry {
        api_key = os.environ.get("GEMINI_API_KEY");
        if not api_key {
            report {"error": "GEMINI_API_KEY is missing."};
            return;
        }

        # NEW: Initialize the client directly
        client = genai.Client(api_key=api_key);

        try {
            print("\n--- NEW INTERVIEW SUBMISSION ---");
            print("1. Decoding video data...");
            encoded_data = self.video_b64.split(",")[1];
            video_data = base64.b64decode(encoded_data);

            temp_file_path = "";
            with tempfile.NamedTemporaryFile(delete=False, suffix=".webm") as temp_video {
                temp_video.write(video_data);
                temp_file_path = temp_video.name;
            }

            print("2. Uploading to Gemini Servers...");
            # NEW: Upload syntax
            video_file = client.files.upload(file=temp_file_path);

            print("3. Waiting for Gemini to process the video...");
            while video_file.state.name == "PROCESSING" {
                print("   ...still processing...");
                time.sleep(5);
                # NEW: File polling syntax
                video_file = client.files.get(name=video_file.name);
            }
            
            if video_file.state.name == "FAILED" {
                print("❌ Error: Gemini failed to process the video.");
                report {"error": "Gemini failed to process the uploaded video."};
                os.remove(temp_file_path);
                return;
            }

            print("4. Generating feedback using Gemini 2.5 Flash...");
            prompt = (
                "You are an expert interview coach. " +
                "The candidate is applying for the role of: " + self.role + ". " +
                "They were asked this question: " + self.question + ". " +
                "Review the attached video response. Evaluate their communication skills, " +
                "clarity, and the technical accuracy of their answer. " +
                "Provide highly actionable, constructive feedback in plain text only. " +
                "Do not use markdown, bold markers, hash headings, or tables. " +
                "Use this exact structure: " +
                "Overall Assessment: short paragraph. " +
                "Strengths: 2-4 bullet points starting with '- '. " +
                "Areas to Improve: 2-4 bullet points starting with '- '. " +
                "Next Practice Step: 1-2 sentences."
            );

            # NEW: Generation syntax
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=[prompt, video_file]
            );

            os.remove(temp_file_path);

            print("5. ✅ Success! Sending feedback to frontend.");
            report {"success": True, "feedback": response.text};

        } except Exception as e {
            print("❌ Backend Error: " + str(e));
            report {"error": "Backend Error: " + str(e)};
        }
    }
}
