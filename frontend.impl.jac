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
    
    # Clean up the camera if the user clicks Home while it's running
    cameraActive = False;
    isRecording = False;
    hasRecorded = False;
    eval("if (window.localStream) { window.localStream.getTracks().forEach(track => track.stop()); }");
}

impl app.startCamera -> None {
    # Request camera/mic permissions and attach stream to the video tag
    eval("navigator.mediaDevices.getUserMedia({video: true, audio: true}).then(stream => { window.localStream = stream; document.getElementById('webcam-video').srcObject = stream; }).catch(err => console.error('Camera error:', err));");
    cameraActive = True;
    hasRecorded = False;
}

impl app.startRecording -> None {
    # Initialize the MediaRecorder and start capturing chunks
    eval("window.mediaRecorder = new MediaRecorder(window.localStream); window.recordedChunks = []; window.mediaRecorder.ondataavailable = (e) => { if (e.data.size > 0) window.recordedChunks.push(e.data); }; window.mediaRecorder.start();");
    isRecording = True;
}

impl app.stopRecording -> None {
    # Stop recording, compile the video into a Blob, and set it to the playback video tag
    eval("window.mediaRecorder.onstop = () => { const blob = new Blob(window.recordedChunks, { type: 'video/webm' }); window.recordedVideoBlob = blob; document.getElementById('playback-video').src = URL.createObjectURL(blob); window.localStream.getTracks().forEach(track => track.stop()); }; window.mediaRecorder.stop();");
    isRecording = False;
    cameraActive = False;
    hasRecorded = True;
}

impl app.resetRecording -> None {
    hasRecorded = False;
    adviceText = ""; # Clear old advice
    eval("document.getElementById('playback-video').src = '';");
    startCamera();
}

impl app.handleGiveFeedback -> None {
    print("User clicked Give Feedback");
}

impl app.handleRefineAdvice -> None {
    print("User clicked Refine Advice");
}

impl app.getFeedback -> None {
    isAnalyzing = True;
    adviceText = "Uploading video to Gemini... This might take up to a minute to process!";

    # Convert the video Blob to a base64 string using JS
    b64_string = await eval("""
        new Promise((resolve) => {
            const reader = new FileReader();
            reader.readAsDataURL(window.recordedVideoBlob);
            reader.onloadend = () => resolve(reader.result);
        })
    """);

    # Call the backend walker we just built
    response = root spawn SubmitInterview(
        role=roleTitle, 
        question=questionText, 
        video_b64=b64_string
    );

    # Update the UI with the result
    if response.reports and response.reports[0]["success"] {
        adviceText = response.reports[0]["feedback"];
    } else {
        adviceText = "Error analyzing video: " + str(response.reports[0]["error"]);
    }
    
    isAnalyzing = False;
}