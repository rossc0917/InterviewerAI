"""Implementations for InterviewerAI frontend."""

sv import from endpoints { SubmitInterview }

impl app.handleRoleSubmit(e: any) -> None {
    e.preventDefault();
    if roleTitle.trim() != "" {
        currentScreen = "question";
    }
}

impl app.handleQuestionSubmit(e: any) -> None {
    e.preventDefault();
    if questionText.trim() != "" {
        currentScreen = "interview";
    }
}

impl app.handleHome -> None {
    currentScreen = "role";
    roleTitle = "";
    questionText = "";
    
    cameraActive = False;
    isRecording = False;
    hasRecorded = False;
    eval("if (window.localStream) { window.localStream.getTracks().forEach(track => track.stop()); }");
}

# FIX: Removed the 'async' keyword here!
impl app.startCamera -> None {
    status = await eval("""
        new Promise((resolve) => {
            navigator.mediaDevices.getUserMedia({video: true, audio: true})
            .then(stream => {
                window.localStream = stream;
                document.getElementById('webcam-video').srcObject = stream;
                resolve("READY");
            })
            .catch(err => {
                console.error('Camera error:', err);
                alert("Could not access camera/microphone. Please check permissions!");
                resolve("ERROR");
            });
        })
    """);

    if status == "READY" {
        cameraActive = True;
        hasRecorded = False;
    }
}

impl app.startRecording -> None {
    is_ready = eval("window.localStream ? 'YES' : 'NO'");
    if is_ready == "NO" {
        eval("alert('Camera is not ready yet!');");
        return;
    }

    eval("""
        window.mediaRecorder = new MediaRecorder(window.localStream); 
        window.recordedChunks = []; 
        window.mediaRecorder.ondataavailable = (e) => { 
            if (e.data.size > 0) window.recordedChunks.push(e.data); 
        }; 
        window.mediaRecorder.start();
    """);
    isRecording = True;
}

impl app.stopRecording -> None {
    eval("window.mediaRecorder.onstop = () => { const blob = new Blob(window.recordedChunks, { type: 'video/webm' }); window.recordedVideoBlob = blob; document.getElementById('playback-video').src = URL.createObjectURL(blob); window.localStream.getTracks().forEach(track => track.stop()); }; window.mediaRecorder.stop();");
    isRecording = False;
    cameraActive = False;
    hasRecorded = True;
}

impl app.resetRecording -> None {
    hasRecorded = False;
    adviceText = "";
    eval("document.getElementById('playback-video').src = '';");
    startCamera();
}

impl app.getFeedback -> None {
    isAnalyzing = True;
<<<<<<< Updated upstream
    adviceText = "Preparing video for upload...";

=======
    adviceText = "Analyzing your communication skills...";

    # 1. Start the tip rotation safely!
    eval("""
        (() => {
            const localTipsBank = [
                "Analyzing your communication skills...",
                "Reviewing technical accuracy...",
                "Evaluating tone and confidence..."
            ];
            
            let tipIndex = 0;
            // Save interval to window so we can stop it later
            window.tipInterval = setInterval(() => {
                tipIndex = (tipIndex + 1) % localTipsBank.length;
                
                // Safety check: Only update if you eventually add id="advice-box" to your UI
                let adviceBox = document.getElementById('advice-box');
                if (adviceBox) {
                    adviceBox.innerText = localTipsBank[tipIndex];
                }
            }, 3000); // 3 seconds feels snappier than 10!
        })();
    """);

    # 2. Package the video
>>>>>>> Stashed changes
    b64_string = await eval("""
        new Promise((resolve) => {
            try {
                if (!window.recordedVideoBlob) {
                    resolve("ERROR: No video found.");
                    return;
                }
                const reader = new FileReader();
                reader.readAsDataURL(window.recordedVideoBlob);
                reader.onloadend = () => resolve(reader.result);
                reader.onerror = () => resolve("ERROR: Failed to read video file.");
            } catch (err) {
                resolve("ERROR: " + err.message);
            }
        })
    """);

    if b64_string.startsWith("ERROR:") {
        adviceText = "Browser Error: " + str(b64_string);
        isAnalyzing = False;
<<<<<<< Updated upstream
        return;
    }

    adviceText = "Uploading video... Watch your terminal to see the live progress!";

=======
        eval("if (window.tipInterval) clearInterval(window.tipInterval);"); # Stop tips!
        return;
    }

    # 3. Send to Server
>>>>>>> Stashed changes
    response = await root spawn SubmitInterview(
        role=roleTitle, 
        question=questionText, 
        video_b64=b64_string
    );

<<<<<<< Updated upstream
=======
    # 4. Handle Response
>>>>>>> Stashed changes
    if response and response.reports and response.reports.length > 0 {
        if response.reports[0]["success"] {
            adviceText = response.reports[0]["feedback"];
        } else {
            adviceText = "Error analyzing video: " + str(response.reports[0]["error"]);
        }
    } else {
        adviceText = "The server timed out or returned an empty response. Check your terminal for the red error logs!";
    }
    
    isAnalyzing = False;
<<<<<<< Updated upstream
}

impl app.handleGiveFeedback -> None {
    print("User clicked Give Feedback");
}

impl app.handleRefineAdvice -> None {
    print("User clicked Refine Advice");
=======
    
    # 5. Stop the loading tips!
    eval("if (window.tipInterval) clearInterval(window.tipInterval);");
>>>>>>> Stashed changes
}