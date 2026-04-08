"""Implementations for InterviewerAI frontend."""

sv import from endpoints { SubmitInterview }

# -------------------------
# Auth handlers
# -------------------------

impl app.handleLogin -> None {
    error = "";
    if not username.trim() or not password {
        error = "Please fill in all fields";
        return;
    }

    loading = True;
    success = await jacLogin(username, password);
    loading = False;

    if success {
        isLoggedIn = True;
        password = "";

        if rememberMe {
            localStorage.setItem("remembered_username", username);
        } else {
            localStorage.removeItem("remembered_username");
        }

        currentScreen = "home";
        selectedHistoryId = "";
        selectedHistoryEntry = null;
        loadInterviewHistory();
    } else {
        error = "Login failed";
    }
}

impl app.handleSignup -> None {
    error = "";
    if not username.trim() or not password {
        error = "Please fill in all fields";
        return;
    }
    if password.length < 4 {
        error = "Password must be at least 4 characters";
        return;
    }

    loading = True;
    result = await jacSignup(username, password);
    loading = False;

    if result and result["success"] {
        # switch back to login mode
        isSignup = False;
        password = "";
        error = "";
    } else {
        if result and result["error"] and result["error"]["message"] {
            error = result["error"]["message"];
        } else {
            error = "Signup failed";
        }
    }
}

impl app.handleSubmit(e: any) -> None {
    e.preventDefault();
    if isSignup {
        await handleSignup();
    } else {
        await handleLogin();
    }
}

impl app.loadInterviewHistory -> None {
    localStorage.setItem("__jac_history_user", username);
    interviewHistory = eval("""
        (function() {
            try {
                var user = localStorage.getItem('__jac_history_user') || '';
                var perUserKey = 'interview_history__' + user;
                var raw = [];
                try {
                    raw = JSON.parse(localStorage.getItem(perUserKey) || '[]');
                } catch (e) {
                    raw = [];
                }
                if (!Array.isArray(raw) || raw.length === 0) {
                    var h = JSON.parse(localStorage.getItem('interview_history') || '{}');
                    raw = h[user] || [];
                    if (Array.isArray(raw) && raw.length > 0) {
                        raw = raw.map(function(entry) {
                            if (!entry || typeof entry !== 'object') return entry;
                            return {
                                id: entry.id || Date.now().toString(),
                                roleTitle: entry.roleTitle || '',
                                questionText: entry.questionText || '',
                                adviceText: entry.adviceText || entry.feedback || '',
                                feedback: entry.feedback || entry.adviceText || '',
                                // Drop old embedded videos during migration so future saves fit.
                                videoDataUrl: '',
                                createdAt: entry.createdAt || Date.now()
                            };
                        });
                        try { localStorage.setItem(perUserKey, JSON.stringify(raw)); } catch (e) { console.warn('History migration failed:', e); }
                    }
                }
                if (!Array.isArray(raw)) return [];
                return raw.map(function(entry) {
                    if (!entry || typeof entry !== 'object') return entry;
                    return {
                        id: entry.id || Date.now().toString(),
                        roleTitle: entry.roleTitle || '',
                        questionText: entry.questionText || '',
                        adviceText: entry.adviceText || entry.feedback || '',
                        feedback: entry.feedback || entry.adviceText || '',
                        videoDataUrl: entry.videoDataUrl || '',
                        createdAt: entry.createdAt || Date.now()
                    };
                });
            } catch (e) {
                console.error('Failed to load interview history', e);
                return [];
            }
        })()
    """);
}

impl app.handleViewHistory(entry: any) -> None {
    selectedHistoryId = entry["id"];
    selectedHistoryEntry = entry;
}

impl app.handleCloseHistory -> None {
    selectedHistoryId = "";
    selectedHistoryEntry = null;
}

impl app.handleLogout -> None {
    jacLogout();
    isLoggedIn = False;

    username = "";
    password = "";
    error = "";
    loading = False;

    # reset interview state
    currentScreen = "auth";
    roleTitle = "";
    questionText = "";
    adviceText = "";
    cameraActive = False;
    isRecording = False;
    hasRecorded = False;
    isAnalyzing = False;
    interviewHistory = [];
    selectedHistoryId = "";
    selectedHistoryEntry = null;

    eval("if (window.localStream) { window.localStream.getTracks().forEach(track => track.stop()); }");
}

impl app.handleNewInterview -> None {
    # start flow
    roleTitle = "";
    questionText = "";
    adviceText = "";
    cameraActive = False;
    isRecording = False;
    hasRecorded = False;
    isAnalyzing = False;

    eval("if (window.localStream) { window.localStream.getTracks().forEach(track => track.stop()); }");

    currentScreen = "role";
}

impl app.handleHome -> None {
    currentScreen = "home";
    selectedHistoryId = "";
    selectedHistoryEntry = null;
    roleTitle = "";
    questionText = "";
    adviceText = "";

    cameraActive = False;
    isRecording = False;
    hasRecorded = False;
    isAnalyzing = False;

    eval("if (window.localStream) { window.localStream.getTracks().forEach(track => track.stop()); }");
    loadInterviewHistory();
}

impl app.handleFinish -> None {
    currentScreen = "interview_finished";
}

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

# -------------------------
# Camera / recording
# -------------------------
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
    adviceText = "Preparing video for upload...";

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
        return;
    }

    adviceText = "Uploading video... Watch your terminal to see the live progress!";

    response = await root spawn SubmitInterview(
        role=roleTitle, 
        question=questionText, 
        video_b64=b64_string
    );

    if response and response.reports and response.reports.length > 0 {
        if response.reports[0]["success"] {
            feedback_text = response.reports[0]["feedback"];
            adviceText = feedback_text;
            localStorage.setItem("__jac_pending_history_user", username);
            localStorage.setItem("__jac_pending_history_role", roleTitle);
            localStorage.setItem("__jac_pending_history_question", questionText);
            localStorage.setItem("__jac_pending_history_feedback", feedback_text);
            # Save to interview history (role, question, video, feedback) for this user
            eval("""
                (function() {
                    var u = localStorage.getItem('__jac_pending_history_user') || '';
                    var perUserKey = 'interview_history__' + u;
                    var userHistory = [];
                    try {
                        userHistory = JSON.parse(localStorage.getItem(perUserKey) || '[]');
                    } catch (e) {
                        userHistory = [];
                    }
                    if (!Array.isArray(userHistory) || userHistory.length === 0) {
                        try {
                            var h = JSON.parse(localStorage.getItem('interview_history') || '{}');
                            userHistory = h[u] || [];
                        } catch (e) {
                            userHistory = [];
                        }
                    }
                    if (!Array.isArray(userHistory)) userHistory = [];
                    var entry = {
                        id: Date.now().toString(),
                        roleTitle: localStorage.getItem('__jac_pending_history_role') || '',
                        questionText: localStorage.getItem('__jac_pending_history_question') || '',
                        adviceText: localStorage.getItem('__jac_pending_history_feedback') || '',
                        feedback: localStorage.getItem('__jac_pending_history_feedback') || '',
                        // Avoid storing the full base64 video in localStorage; it can
                        // exceed quota and prevent the entire history entry from saving.
                        videoDataUrl: '',
                        createdAt: Date.now()
                    };
                    userHistory.push(entry);
                    if (userHistory.length > 10) userHistory = userHistory.slice(-10);
                    try { localStorage.setItem(perUserKey, JSON.stringify(userHistory)); } catch (e) { console.warn('History save failed (quota?):', e); }
                    localStorage.removeItem('__jac_pending_history_user');
                    localStorage.removeItem('__jac_pending_history_role');
                    localStorage.removeItem('__jac_pending_history_question');
                    localStorage.removeItem('__jac_pending_history_feedback');
                })()
            """);
            loadInterviewHistory();
        } else {
            adviceText = "Error analyzing video: " + str(response.reports[0]["error"]);
        }
    } else {
        adviceText = "The server timed out or returned an empty response. Check your terminal for the red error logs!";
    }
    
    isAnalyzing = False;
}

# Don't print, just placeholders for now
impl app.handleGiveFeedback -> None {
    print("User clicked Give Feedback");
}

impl app.handleRefineAdvice -> None {
    print("User clicked Refine Advice");
}
