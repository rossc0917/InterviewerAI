"""InterviewerAI - Client UI."""

def:pub app {
    # State Management
    has currentScreen: str = "role",
        roleTitle: str = "",
        questionText: str = "",
        cameraActive: bool = False,
        isRecording: bool = False,
        hasRecorded: bool = False,
        adviceText: str = "",
        isAnalyzing: bool = False;

    # Function Signatures
    def handleRoleSubmit(e: any) -> None;
    def handleQuestionSubmit(e: any) -> None;
    def handleHome -> None;
    def handleGiveFeedback -> None;
    def handleRefineAdvice -> None;
    async def startCamera -> None;  # <--- Make this async
    def startRecording -> None;
    def stopRecording -> None;
    def resetRecording -> None;
    async def getFeedback -> None;

    # Shared Button Styles
    dark_btn_style = {
        "backgroundColor": "#2d2d2d",
        "color": "white",
        "border": "none",
        "padding": "0.6rem 1.2rem",
        "borderRadius": "4px",
        "cursor": "pointer",
        "fontSize": "1rem"
    };

    home_btn_style = {
        **dark_btn_style,
        "position": "absolute",
        "top": "2rem",
        "right": "2rem"
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

    # ==========================================
    # SCREEN 1: Role Input
    # ==========================================
    if currentScreen == "role" {
        return
            <div style={{
                "display": "flex", "flexDirection": "column", 
                "justifyContent": "center", "alignItems": "center",
                "height": "100vh", "fontFamily": "sans-serif"
            }}>
                <h1 style={{"fontSize": "2.5rem", "marginBottom": "2rem", "fontWeight": "normal"}}>
                    What role are you applying to?
                </h1>
                
                <form onSubmit={handleRoleSubmit} style={{"display": "flex", "gap": "1rem", "width": "500px"}}>
                    <input 
                        type="text" 
                        value={roleTitle}
                        onChange={lambda e: any -> None { roleTitle = e.target.value; }}
                        placeholder="e.g. Quantitative Analyst"
                        style={input_style}
                    />
                    <button type="submit" style={{**dark_btn_style, "height": "52px"}}>
                        Submit
                    </button>
                </form>
            </div>;
    }

    # ==========================================
    # SCREEN 2: Question Input
    # ==========================================
    if currentScreen == "question" {
        return
            <div style={{
                "display": "flex", "flexDirection": "column", 
                "justifyContent": "center", "alignItems": "center",
                "height": "100vh", "fontFamily": "sans-serif"
            }}>
                <button onClick={handleHome} style={home_btn_style}>Home</button>

                <h1 style={{"fontSize": "2.5rem", "marginBottom": "2rem", "fontWeight": "normal"}}>
                    What question are you going to answer?
                </h1>
                
                <form onSubmit={handleQuestionSubmit} style={{"display": "flex", "gap": "1rem", "width": "500px"}}>
                    <input 
                        type="text" 
                        value={questionText}
                        onChange={lambda e: any -> None { questionText = e.target.value; }}
                        placeholder="e.g. Walk me through your mental math process..."
                        style={input_style}
                    />
                    <button type="submit" style={{**dark_btn_style, "height": "52px"}}>
                        Submit
                    </button>
                </form>
            </div>;
    }

    # ==========================================
    # SCREEN 3: Interview / Advice Split
    # ==========================================
    if currentScreen == "interview" {
        return
            <div style={{
                "padding": "4rem", "height": "100vh", 
                "boxSizing": "border-box", "fontFamily": "sans-serif"
            }}>
                <button onClick={handleHome} style={home_btn_style}>Home</button>

                <div style={{
                    "display": "flex", "gap": "4rem", "height": "100%", "alignItems": "center"
                }}>
                    
                    <div style={{
                        "flex": "1", 
                        "height": "400px", 
                        "backgroundColor": "#f0f0f0",
                        "border": "2px solid #333",
                        "borderRadius": "24px",
                        "display": "flex",
                        "justifyContent": "center",
                        "alignItems": "center",
                        "position": "relative",
                        "overflow": "hidden"
                    }}>
                        
                        <video 
                            id="webcam-video" 
                            autoPlay={True} 
                            muted={True} 
                            playsInline={True} 
                            style={{
                                "width": "100%", "height": "100%", 
                                "objectFit": "cover", 
                                "display": "none" if hasRecorded else "block"
                            }}
                        />
                        
                        <video 
                            id="playback-video" 
                            controls={True} 
                            style={{
                                "width": "100%", "height": "100%", 
                                "objectFit": "cover", 
                                "display": "block" if hasRecorded else "none"
                            }}
                        />

                        <div style={{
                            "position": "absolute", "bottom": "20px", 
                            "display": "flex", "gap": "1rem"
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

                    <div style={{"flex": "1", "display": "flex", "flexDirection": "column", "justifyContent": "space-between", "height": "400px"}}>
                        <div>
                            <h2 style={{"fontSize": "2rem", "marginBottom": "1rem", "textAlign": "center", "fontWeight": "normal"}}>
                                Advice
                            </h2>
                            <div style={{
                                "lineHeight": "1.6", "fontSize": "1rem", "color": "#333", 
                                "whiteSpace": "pre-wrap", "overflowY": "auto", "maxHeight": "250px"
                            }}>
                                {adviceText if adviceText else "Record a video and click 'Get Feedback' to see your personalized coaching advice here!"}
                            </div>
                        </div>
                        
                        <div style={{"display": "flex", "gap": "1rem", "justifyContent": "center", "marginTop": "2rem"}}>
                            {(
                                <button onClick={getFeedback} disabled={isAnalyzing} style={{**dark_btn_style, "backgroundColor": "#4CAF50" if not isAnalyzing else "#9ca3af", "padding": "1rem 2rem"}}>
                                    { "Analyzing Video..." if isAnalyzing else "Get Feedback from Gemini" }
                                </button>
                            ) if hasRecorded and not adviceText else None}

                            {(
                                <button onClick={handleGiveFeedback} style={{**dark_btn_style, "padding": "1rem 2rem"}}>
                                    Give Feedback on Advice
                                </button>
                            ) if adviceText else None}
                        </div>
                    </div>
                </div>
            </div>;
    }
}