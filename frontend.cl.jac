"""InterviewerAI - Client UI."""

cl import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }
cl import from .components.AuthForm { AuthForm }
cl import "./assets/styles.css";


def:pub app {

    # ==============================
    # AUTH STATE
    # ==============================

    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        rememberMe: bool = False;

    # ==============================
    # INTERVIEW APP STATE
    # ==============================

    has currentScreen: str = "home",
        roleTitle: str = "",
        questionText: str = "",
        cameraActive: bool = False,
        isRecording: bool = False,
        hasRecorded: bool = False,
        adviceText: str = "",
        isAnalyzing: bool = False,
        currentTip: str = "Preparing your feedback...",
        tipTimer: any = None;


    has tipsBank: list = [
        "Take a deep breath. You're doing great!",
        "Remember to maintain eye contact with the camera.",
        "The STAR method (Situation, Task, Action, Result) is your best friend.",
        "Keep your posture upright to project confidence.",
        "Small pauses are okay; they show you are thinking.",
        "Dress for the job you want, even in a mock interview.",
        "Research the company's culture before the real thing.",
        "Smile! It makes you sound more energetic and approachable.",
        "Focus on your specific contributions in group projects.",
        "Confidence comes from preparation.",
        "Practice makes permanent. Keep recording!",
        "Think of the interviewer as a future colleague, not an opponent.",
        "Be specific. Use numbers and data to back up your achievements.",
        "It's okay to ask for a moment to collect your thoughts.",
        "Listen carefully to the question before you start answering.",
        "Your unique perspective is your greatest strength.",
        "Remember to mention not just what you did, but the impact it had.",
        "Keep your background tidy for virtual interviews.",
        "Pace yourself; speaking too fast can make you seem nervous.",
        "Body language speaks louder than words.",
        "Acknowledge your mistakes, but focus on what you learned from them.",
        "Research your interviewers on LinkedIn if possible.",
        "Have 2-3 questions ready to ask the interviewer.",
        "Show enthusiasm for the role and the company.",
        "Match your skills to the specific job description.",
        "Confidence is silent; insecurities are loud. Stay calm.",
        "Don't just list tasks—tell a story of growth.",
        "Technical skills get you the interview; soft skills get you the job.",
        "Be honest about your weaknesses, but show how you're improving.",
        "Treat every mock interview as the real deal.",
        "Your energy is contagious. Keep it positive!",
        "Drink some water before you start to avoid a dry throat.",
        "Ensure your lighting is in front of you, not behind you.",
        "Preparation is the antidote to fear.",
        "Focus on 'we' for teamwork, but 'I' for your specific actions.",
        "Every 'no' is just a step closer to the right 'yes'.",
        "Silence is better than 'um', 'uh', or 'like'.",
        "Be authentic. People hire people, not resumes.",
        "Visualize yourself succeeding before you press record.",
        "Check your internet connection one last time.",
        "Summarize your key points at the end of a long answer.",
        "Relate your past experiences to the company's future goals.",
        "Keep your answers concise—usually between 1 and 2 minutes.",
        "Don't be afraid to show a little personality.",
        "Answering 'I don't know' is better than making something up.",
        "Reflect on your values and how they align with the role.",
        "Think about your 'Greatest Hits'—your top 3 proudest moments.",
        "The more you do this, the more natural it will feel.",
        "You have the skills; now you just have to show them.",
        "Believe in yourself. You’ve worked hard to get here!",
        "You are a STAR!"
    ];
    # ==============================
    # INITIAL AUTH CHECK
    # ==============================

    can with entry {
        # Default safe state
        isLoggedIn = False;
        currentScreen = "auth";

        # Safe check for auth (wrap via eval try/catch)
        logged = eval("""
            (() => {
                try { return jacIsLoggedIn(); }
                catch (e) { console.error("jacIsLoggedIn crashed", e); return false; }
            })()
        """);
        isLoggedIn = True if logged else False;

        # Safe localStorage access
        savedUser = eval("""
            (() => {
                try { return localStorage.getItem("remembered_username"); }
                catch (e) { console.error("localStorage crashed", e); return null; }
            })()
        """);

        if savedUser {
            username = savedUser;
            rememberMe = True;
        }

        currentScreen = ("home" if isLoggedIn else "auth");
        checkingAuth = False;
    }

    # ==============================
    # FUNCTION SIGNATURES
    # ==============================

    async def handleLogin -> None;
    async def handleSignup -> None;
    async def handleSubmit(e: any) -> None;

    def handleLogout -> None;
    def handleNewInterview -> None;

    def handleRoleSubmit(e: any) -> None;
    def handleQuestionSubmit(e: any) -> None;
    def handleHome -> None;

    def handleGiveFeedback -> None;
    def handleRefineAdvice -> None;

    async def startCamera -> None;
    def startRecording -> None;
    def stopRecording -> None;
    def resetRecording -> None;
    async def getFeedback -> None;

    # ==============================
    # SHARED STYLES
    # ==============================

    dark_btn_style = {
        "backgroundColor": "#2d2d2d",
        "color": "white",
        "border": "none",
        "padding": "0.6rem 1.2rem",
        "borderRadius": "6px",
        "cursor": "pointer",
        "fontSize": "1rem"
    };

    home_btn_style = {
        **dark_btn_style,
        "position": "absolute",
        "top": "2rem",
        "right": "2rem"
    };

    back_btn_style = {
        **dark_btn_style,
        "position": "absolute",
        "top": "2rem",
        "left": "2rem"
    };

    input_style = {
        "width": "100%",
        "padding": "1rem",
        "backgroundColor": "#e8e6ea",
        "border": "none",
        "borderRadius": "4px",
        "fontSize": "1rem",
        "marginBottom": "1rem",
        "outline": "none"
    };

    # ==============================
    # LOADING SCREEN
    # ==============================

    if checkingAuth {
        return
            <div style={{
                "display": "flex",
                "justifyContent": "center",
                "alignItems": "center",
                "height": "100vh",
                "fontFamily": "sans-serif"
            }}>
                Loading...
            </div>;
    }

    # ==============================
    # AUTH SCREEN
    # ==============================

    if not isLoggedIn {
        return
            <AuthForm
                isSignup={isSignup}
                username={username}
                password={password}
                rememberMe={rememberMe}
                error={error}
                loading={loading}
                onUsernameChange={lambda e: any -> None { username = e.target.value; }}
                onPasswordChange={lambda e: any -> None { password = e.target.value; }}
                onRememberChange={lambda e: any -> None { rememberMe = e.target.checked; }}
                onSubmit={handleSubmit}
                onToggleMode={lambda -> None { isSignup = not isSignup; error = ""; }}
            />;
    }

    # ==============================
    # HOME SCREEN
    # ==============================

    if currentScreen == "home" {

        return
            <div class="home-page">

                <div class="topbar">
                    <div class="topbar-left">
                        <img class="top-logo" src="/interviewerai-logo-full.png" />
                    </div>

                    <div class="topbar-center">
                        <h1 class="home-title">InterviewerAI</h1>
                    </div>

                    <div class="topbar-right">
                        <button onClick={handleLogout} class="logout-btn">
                            Log Out
                        </button>
                    </div>
                </div>

                <div class="home-content">
                    <button
                        onClick={handleNewInterview}
                        class="start-btn"
                    >
                        Start New Interview
                    </button>
                </div>

            </div>;
    }

    # ==============================
    # ROLE SCREEN
    # ==============================

    if currentScreen == "role" {

        return
            <div style={{
                "display": "flex",
                "flexDirection": "column",
                "justifyContent": "center",
                "alignItems": "center",
                "height": "100vh",
                "fontFamily": "sans-serif"
            }}>

                <button onClick={handleHome} style={home_btn_style}>Home</button>

                <h1 style={{"fontSize": "2.5rem", "marginBottom": "2rem"}}>
                    What role are you applying to?
                </h1>

                <form onSubmit={handleRoleSubmit} style={{"width": "500px"}}>

                    <input
                        type="text"
                        value={roleTitle}
                        placeholder="e.g. Quantitative Analyst"
                        onChange={lambda e: any -> None { roleTitle = e.target.value; }}
                        style={input_style}
                    />

                    <button type="submit" style={dark_btn_style}>
                        Continue
                    </button>

                </form>
            </div>;
    }

    # ==============================
    # QUESTION SCREEN
    # ==============================

    if currentScreen == "question" {

        return
            <div style={{
                "display": "flex",
                "flexDirection": "column",
                "justifyContent": "center",
                "alignItems": "center",
                "height": "100vh",
                "fontFamily": "sans-serif"
            }}>

                <button onClick={lambda -> None { currentScreen = "role"; }} style={back_btn_style}>
                    Back
                </button>

                <button onClick={handleHome} style={home_btn_style}>Home</button>

                <h1 style={{"fontSize": "2.5rem", "marginBottom": "2rem"}}>
                    What question are you answering?
                </h1>

                <form onSubmit={handleQuestionSubmit} style={{"width": "500px"}}>

                    <input
                        type="text"
                        value={questionText}
                        placeholder="Tell me about a challenge..."
                        onChange={lambda e: any -> None { questionText = e.target.value; }}
                        style={input_style}
                    />

                    <button type="submit" style={dark_btn_style}>
                        Continue
                    </button>

                </form>
            </div>;
    }

    # ==============================
    # INTERVIEW SCREEN
    # ==============================

    if currentScreen == "interview" {

        return
            <div style={{
                "padding": "4rem",
                "height": "100vh",
                "fontFamily": "sans-serif"
            }}>

                <button onClick={handleHome} style={home_btn_style}>Home</button>

                <div style={{
                    "marginBottom": "2rem"
                }}>
                    <h1 style={{
                        "fontSize": "2rem",
                        "margin": "0 0 0.25rem 0"
                    }}>
                        {roleTitle if roleTitle else "Your interview role"}
                    </h1>
                    <p style={{
                        "fontSize": "1.1rem",
                        "color": "#4b5563",
                        "margin": "0"
                    }}>
                        {questionText if questionText else "Your interview question will appear here."}
                    </p>
                </div>

                <div style={{
                    "display": "flex",
                    "gap": "4rem",
                    "alignItems": "center"
                }}>

                    <div style={{
                        "flex": "1",
                        "height": "400px",
                        "backgroundColor": "#f0f0f0",
                        "border": "2px solid #333",
                        "borderRadius": "24px",
                        "overflow": "hidden",
                        "display": "flex",
                        "justifyContent": "center",
                        "alignItems": "center",
                        "position": "relative"
                    }}>

                        <video id="webcam-video"
                            autoPlay={True}
                            muted={True}
                            playsInline={True}
                            style={{
                                "width": "100%",
                                "height": "100%",
                                "objectFit": "cover",
                                "borderRadius": "inherit",
                                "display": "none" if hasRecorded else "block"
                            }}
                        />

                        <video id="playback-video"
                            controls={True}
                            style={{
                                "width": "100%",
                                "height": "100%",
                                "objectFit": "cover",
                                "borderRadius": "inherit",
                                "display": "block" if hasRecorded else "none"
                            }}
                        />

                        <div style={{
                            "position": "absolute",
                            "bottom": "20px",
                            "display": "flex",
                            "gap": "1rem"
                        }}>
                            {(
                                <button onClick={startCamera} style={dark_btn_style}>
                                    Turn on Camera
                                </button>
                            ) if not cameraActive and not hasRecorded else None}

                            {(
                                <button onClick={startRecording} style={{**dark_btn_style, "backgroundColor": "#dc3545"}}>
                                    Start Recording
                                </button>
                            ) if cameraActive and not isRecording else None}

                            {(
                                <button onClick={stopRecording} style={dark_btn_style}>
                                    Stop Recording
                                </button>
                            ) if isRecording else None}

                            {(
                                <button onClick={resetRecording} style={dark_btn_style}>
                                    Retake Video
                                </button>
                            ) if hasRecorded else None}
                        </div>

                    </div>

                    <div style={{"flex": "1"}}>

                        <h2>Advice</h2>

                        <div style={{
                            "whiteSpace": "pre-wrap",
                            "minHeight": "200px",
                            "padding": "1rem 1.25rem",
                            "backgroundColor": "#f8f9fb",
                            "border": "1px solid #d9dde5",
                            "borderRadius": "12px",
                            "lineHeight": "1.65",
                            "fontSize": "1rem",
                            "color": "#1f2937",
                            "overflowY": "auto"
                        }}>
                            {currentTip if isAnalyzing else (adviceText if adviceText else "Record a video and request feedback.")}
                        </div>

                        {(
                            <button
                                onClick={getFeedback}
                                disabled={isAnalyzing}
                                style={dark_btn_style}
                            >
                                {"Analyzing..." if isAnalyzing else "Get Feedback"}
                            </button>
                        ) if hasRecorded and (isAnalyzing or not adviceText) else None}

                    </div>

                </div>
            </div>;
    }
}
