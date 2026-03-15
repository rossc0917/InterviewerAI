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
        interviewHistory: any = [],
        selectedHistoryId: str = "",
        selectedHistoryEntry: any = null;

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
        if isLoggedIn {
            loadInterviewHistory();
        }
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

    def loadInterviewHistory -> None;
    def handleViewHistory(entry: any) -> None;
    def handleViewHistoryById(id: str) -> None;
    def getClickHandler(id: str) -> any;
    def handleCloseHistory -> None;

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

        # History detail view (clicked a past interaction)
        if selectedHistoryEntry {
            ent = selectedHistoryEntry;
            return
                <div class="home-page" style={{"paddingBottom": "3rem"}}>
                    <div class="topbar">
                        <div class="topbar-left">
                            <img class="top-logo" src="/interviewerai-logo-full.png" />
                        </div>
                        <div class="topbar-center">
                            <h1 class="home-title">InterviewerAI</h1>
                        </div>
                        <div class="topbar-right">
                            <button onClick={handleLogout} class="logout-btn">Log Out</button>
                        </div>
                    </div>
                    <div style={{
                        "padding": "2rem 4rem",
                        "maxWidth": "1200px",
                        "margin": "0 auto"
                    }}>
                        <button
                            onClick={handleCloseHistory}
                            style={{**back_btn_style, "position": "relative", "top": "0", "left": "0", "marginBottom": "1.5rem"}}
                        >
                            ← Back to Home
                        </button>
                        <div style={{"marginBottom": "1.5rem"}}>
                            <h1 style={{"fontSize": "1.75rem", "margin": "0 0 0.25rem 0"}}>
                                {ent["roleTitle"] if ent["roleTitle"] else "Role"}
                            </h1>
                            <p style={{"fontSize": "1rem", "color": "var(--text-muted)", "margin": "0"}}>
                                {ent["questionText"] if ent["questionText"] else "Question"}
                            </p>
                        </div>
                        <div style={{
                            "display": "grid",
                            "gridTemplateColumns": "1fr 1fr",
                            "gap": "2rem",
                            "alignItems": "start"
                        }}>
                            <div style={{
                                "backgroundColor": "var(--panel)",
                                "borderRadius": "12px",
                                "overflow": "hidden",
                                "aspectRatio": "16/10"
                            }}>
                                <video
                                    src={ent["videoDataUrl"] if ent["videoDataUrl"] else ""}
                                    controls={True}
                                    style={{"width": "100%", "height": "100%", "objectFit": "contain"}}
                                />
                            </div>
                            <div>
                                <h2 style={{"fontSize": "1.25rem", "marginBottom": "0.75rem"}}>Feedback</h2>
                                <div style={{
                                    "whiteSpace": "pre-wrap",
                                    "padding": "1rem 1.25rem",
                                    "backgroundColor": "var(--panel)",
                                    "border": "1px solid var(--border)",
                                    "borderRadius": "12px",
                                    "lineHeight": "1.65",
                                    "fontSize": "1rem",
                                    "color": "var(--text-main)",
                                    "minHeight": "200px"
                                }}>
                                    {ent["adviceText"] if ent["adviceText"] else "No feedback saved."}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>;
        }

        # Build history list items (so each click handler is bound to the correct id)
        historyItems = [];
        i = 0;
        while i < interviewHistory.length {
            ent = interviewHistory[i];
            id_val = ent["id"];
            h = getClickHandler(id_val);
            historyItems = historyItems + [
                <div
                    key={id_val}
                    onClick={h}
                    class="history-item"
                    style={{
                        "padding": "1rem 1.25rem",
                        "marginBottom": "0.75rem",
                        "backgroundColor": "var(--panel)",
                        "border": "1px solid var(--border)",
                        "borderRadius": "10px",
                        "cursor": "pointer",
                        "transition": "all 0.2s ease"
                    }}
                >
                    <div style={{"fontWeight": "700", "fontSize": "1.05rem"}}>
                        {ent["roleTitle"] if ent["roleTitle"] else "Interview"}
                    </div>
                    <div style={{"fontSize": "0.9rem", "color": "var(--text-muted)", "marginTop": "0.25rem"}}>
                        {ent["questionText"] if ent["questionText"] else "—"}
                    </div>
                    <div style={{"fontSize": "0.8rem", "color": "var(--text-muted)", "marginTop": "0.5rem"}}>
                        {eval("(function(t){ return t ? new Date(t).toLocaleDateString() + ' ' + new Date(t).toLocaleTimeString() : ''; })(" + str(ent["createdAt"]) + ")")}
                    </div>
                </div>
            ];
            i = i + 1;
        }

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

                <div class="home-content" style={{"flexDirection": "column", "alignItems": "center", "gap": "2rem"}}>
                    <button
                        onClick={handleNewInterview}
                        class="start-btn"
                    >
                        Start New Interview
                    </button>

                    <div style={{"width": "100%", "maxWidth": "600px"}}>
                        <h2 style={{"fontSize": "1.5rem", "marginBottom": "1rem", "textAlign": "center"}}>
                            Past interviews
                        </h2>
                        <div style={{"minHeight": "80px"}}>
                            {historyItems if historyItems.length > 0 else <p style={{"color": "var(--text-muted)", "textAlign": "center"}}>No past interviews yet. Complete an interview and get feedback to see it here.</p>}
                        </div>
                    </div>
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
                            {adviceText if adviceText else "Record a video and request feedback."}
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
