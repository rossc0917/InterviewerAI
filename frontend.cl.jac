"""Todo App - Client-Side UI."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import from .components.AuthForm { AuthForm }

sv import from main { Interview, GetInterviewItems }

def:pub app -> any {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        rememberMe: bool = False,

        # Interview flow state
        showRoleInput: bool = False,
        showQuestionInput: bool = False,
        roleTitle: str = "",
        jobId: str = "",
        questionText: str = "",
        showInterviewContext: bool = False;
        
    can with entry {
        isLoggedIn = jacIsLoggedIn();
        savedUser = localStorage.getItem("remembered_username");
        if savedUser {
            username = savedUser;
            rememberMe = True;
        }
        checkingAuth = False;
    }

    async def handleLogin -> None;
    async def handleSignup -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;

    def handleNewInterview -> None {
        showRoleInput = True;
        showQuestionInput = False;
    }

    def handleRoleSubmit(e: any) -> None {
        e.preventDefault();
        if roleTitle == "" {
            return;
        }

        showRoleInput = False;
        showQuestionInput = True;
    }

    def handleBackToRole -> None {
        showQuestionInput = False;
        showRoleInput = True;
    }

    def handleHome -> None {
        showRoleInput = False;
        showQuestionInput = False;
        showInterviewContext = False;

        roleTitle = "";
        questionText = "";
        jobId = "";
    }

    def handleQuestionSubmit(e: any) -> None {
        showQuestionInput = False;
        showInterviewContext = True;
    }

    # Loading screen
    if checkingAuth {
        return
            <div style={{
                "display": "flex",
                "justifyContent": "center",
                "alignItems": "center",
                "height": "100vh",
                "fontFamily": "system-ui, -apple-system, sans-serif",
                "color": "#666"
            }}>
                Loading...
            </div>;
    }

    # Logged in
    if isLoggedIn {

        # Interview context screen
        if showInterviewContext {
            return
                <div style={{
                    "height": "100vh",
                    "fontFamily": "system-ui, sans-serif",
                    "display": "flex",
                    "flexDirection": "column"
                }}>
                    <div style={{
                        "display": "flex",
                        "justifyContent": "flex-start",
                        "alignItems": "center",
                        "padding": "1rem 1.5rem",
                        "borderBottom": "1px solid #ddd"
                    }}>
                        <button onClick={handleHome} style={{
                            "padding": "0.5rem 1rem",
                            "borderRadius": "6px",
                            "border": "1px solid #ccc",
                            "backgroundColor": "#f8f9fa",
                            "cursor": "pointer"
                        }}>
                            Home
                        </button>
                    </div>

                    <div style={{
                        "flex": "1",
                        "display": "flex",
                        "flexDirection": "column",
                        "justifyContent": "center",
                        "alignItems": "center"
                    }}>
                        <h2>Interview Context</h2>
                        <p><strong>Username:</strong> {username}</p>
                        <p><strong>Job ID:</strong> {jobId}</p>
                        <p><strong>Role Applying For:</strong> {roleTitle}</p>
                        <p><strong>Question:</strong> {questionText}</p>
                    </div>
                </div>;
        }
        # Question input screen
        if showQuestionInput {
            return
                <div style={{
                    "height": "100vh",
                    "fontFamily": "system-ui, -apple-system, sans-serif",
                    "display": "flex",
                    "flexDirection": "column"
                }}>

                    <div style={{
                        "display": "flex",
                        "justifyContent": "space-between",
                        "alignItems": "center",
                        "padding": "1rem 1.5rem",
                        "borderBottom": "1px solid #ddd"
                    }}>
                        <div style={{
                            "fontSize": "0.9rem",
                            "color": "#555"
                        }}>
                            Role: {roleTitle}
                        </div>

                        <button
                            onClick={handleHome}
                            style={{
                                "padding": "0.4rem 0.8rem",
                                "fontSize": "0.9rem",
                                "borderRadius": "6px",
                                "border": "1px solid #ccc",
                                "backgroundColor": "#f8f9fa",
                                "cursor": "pointer"
                            }}
                        >
                            Home
                        </button>
                    </div>

                    <div style={{
                        "flex": "1",
                        "display": "flex",
                        "flexDirection": "column",
                        "justifyContent": "center",
                        "alignItems": "center"
                    }}>
                        <h2 style={{"marginBottom": "1rem"}}>
                            Type the question you are answering
                        </h2>

                        <form onSubmit={handleQuestionSubmit} style={{"width": "60%"}}>
                            <textarea
                                value={questionText}
                                onChange={lambda e: any -> None { questionText = e.target.value; }}
                                placeholder="e.g. Tell me about a time you faced a challenge..."
                                style={{
                                    "width": "100%",
                                    "height": "120px",
                                    "padding": "0.75rem",
                                    "fontSize": "1rem",
                                    "borderRadius": "6px",
                                    "border": "1px solid #ccc"
                                }}
                            />

                            <div style={{
                                "display": "flex",
                                "justifyContent": "space-between",
                                "marginTop": "1rem"
                            }}>
                                <button
                                    type="button"
                                    onClick={handleBackToRole}
                                    style={{
                                        "padding": "0.5rem 1rem",
                                        "borderRadius": "6px",
                                        "border": "1px solid #ccc",
                                        "backgroundColor": "#f8f9fa",
                                        "cursor": "pointer"
                                    }}
                                >
                                    Back
                                </button>

                                <button
                                    type="submit"
                                    style={{
                                        "padding": "0.6rem 1.2rem",
                                        "borderRadius": "6px",
                                        "border": "none",
                                        "backgroundColor": "#4CAF50",
                                        "color": "white",
                                        "cursor": "pointer"
                                    }}
                                >
                                    Submit Question
                                </button>
                            </div>
                        </form>
                    </div>
                </div>;
        }

        # Role input screen
        if showRoleInput {
            return
                <div style={{
                    "display": "flex",
                    "flexDirection": "column",
                    "justifyContent": "center",
                    "alignItems": "center",
                    "height": "100vh",
                    "fontFamily": "system-ui, -apple-system, sans-serif"
                }}>
                    <h1 style={{
                        "fontSize": "2.5rem",
                        "marginBottom": "1.5rem",
                        "color": "#1a1a2e"
                    }}>
                        What role are you applying to?
                    </h1>

                    <form onSubmit={handleRoleSubmit} style={{"width": "300px"}}>
                        <input
                            type="text"
                            value={roleTitle}
                            placeholder="e.g. Software Engineer"
                            onChange={lambda e: any -> None { roleTitle = e.target.value; }}
                            style={{
                                "width": "100%",
                                "padding": "0.75rem",
                                "fontSize": "1.1rem",
                                "borderRadius": "6px",
                                "border": "1px solid #ccc"
                            }}
                        />

                        <button
                            type="submit"
                            style={{
                                "marginTop": "1rem",
                                "width": "100%",
                                "padding": "0.6rem",
                                "fontSize": "1rem",
                                "borderRadius": "6px",
                                "border": "none",
                                "backgroundColor": "#4CAF50",
                                "color": "white",
                                "cursor": "pointer"
                            }}
                        >
                            Continue
                        </button>
                    </form>
                </div>;
        }

        # Home screen
        return
            <div style={{
                "maxWidth": "600px",
                "margin": "2rem auto",
                "padding": "2rem",
                "fontFamily": "system-ui, -apple-system, sans-serif"
            }}>
                <div style={{
                    "display": "flex",
                    "justifyContent": "space-between",
                    "alignItems": "center",
                    "marginBottom": "1.5rem"
                }}>
                    <h1 style={{"margin": "0", "color": "#1a1a2e"}}>
                        InterviewerAI
                    </h1>
                    <button onClick={handleLogout} style={{
                        "padding": "0.5rem 1rem",
                        "fontSize": "0.9rem",
                        "backgroundColor": "#f8f9fa",
                        "color": "#666",
                        "border": "1px solid #ddd",
                        "borderRadius": "6px",
                        "cursor": "pointer"
                    }}>
                        Log Out
                    </button>
                </div>

                <div style={{"textAlign": "center", "marginTop": "2rem"}}>
                    <button onClick={handleNewInterview} style={{
                        "padding": "1rem 2rem",
                        "fontSize": "1.2rem",
                        "backgroundColor": "#4CAF50",
                        "color": "white",
                        "border": "none",
                        "borderRadius": "8px",
                        "cursor": "pointer"
                    }}>
                        New Interview Job
                    </button>
                </div>
            </div>;
    }

    # Not logged in
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