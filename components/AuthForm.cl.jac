"""Authentication form component for login/signup."""

def:pub AuthForm(
    isSignup: bool,
    username: str,
    password: str,
    error: str,
    loading: bool,
    rememberMe: bool,
    onRememberChange: any,
    onUsernameChange: any,
    onPasswordChange: any,
    onSubmit: any,
    onToggleMode: any
) -> any {
    return
        <div style={{
            "maxWidth": "420px",
            "margin": "5rem auto",
            "padding": "2rem",
            "fontFamily": "system-ui, -apple-system, sans-serif",
            "backgroundColor": "#fff",
            "borderRadius": "12px",
            "boxShadow": "0 8px 22px rgba(0,0,0,0.10)"
        }}>
            <h1 style={{
                "marginBottom": "0.25rem",
                "color": "#111827",
                "textAlign": "center",
                "fontSize": "1.8rem",
                "fontWeight": "700"
            }}>
                InterviewerAI
            </h1>

            <p style={{
                "marginBottom": "1.5rem",
                "color": "#6b7280",
                "textAlign": "center"
            }}>
                {("Create an account" if isSignup else "Sign in to your account")}
            </p>

            {(
                <div style={{
                    "padding": "0.75rem",
                    "marginBottom": "1rem",
                    "backgroundColor": "#fef2f2",
                    "color": "#991b1b",
                    "borderRadius": "8px",
                    "fontSize": "0.95rem",
                    "border": "1px solid #fecaca"
                }}>
                    {error}
                </div>
            ) if error else None}

            <form onSubmit={onSubmit}>
                <input
                    type="text"
                    value={username}
                    onChange={onUsernameChange}
                    placeholder="Username"
                    style={{
                        "width": "100%",
                        "padding": "0.85rem 1rem",
                        "marginBottom": "0.75rem",
                        "fontSize": "1rem",
                        "borderRadius": "10px",
                        "border": "1px solid #e5e7eb",
                        "outline": "none",
                        "boxSizing": "border-box",
                        "backgroundColor": "#f9fafb"
                    }}
                />
                <input
                    type="password"
                    value={password}
                    onChange={onPasswordChange}
                    placeholder="Password"
                    style={{
                        "width": "100%",
                        "padding": "0.85rem 1rem",
                        "marginBottom": "1rem",
                        "fontSize": "1rem",
                        "borderRadius": "10px",
                        "border": "1px solid #e5e7eb",
                        "outline": "none",
                        "boxSizing": "border-box",
                        "backgroundColor": "#f9fafb"
                    }}
                />

                <div style={{
                    "display": "flex",
                    "alignItems": "center",
                    "gap": "0.5rem",
                    "marginBottom": "1rem"
                }}>
                    <input
                        type="checkbox"
                        checked={rememberMe}
                        onChange={onRememberChange}
                    />
                    <label style={{"fontSize": "0.95rem", "color": "#374151"}}>
                        Remember me
                    </label>
                </div>

                <button
                    type="submit"
                    disabled={loading}
                    style={{
                        "width": "100%",
                        "padding": "0.9rem",
                        "fontSize": "1rem",
                        "fontWeight": "600",
                        "backgroundColor": ("#9ca3af" if loading else "#111827"),
                        "color": "white",
                        "border": "none",
                        "borderRadius": "10px",
                        "cursor": ("not-allowed" if loading else "pointer"),
                        "marginBottom": "1rem"
                    }}
                >
                    {("Processing..." if loading else ("Sign Up" if isSignup else "Log In"))}
                </button>
            </form>

            <p style={{"textAlign": "center", "color": "#6b7280", "fontSize": "0.95rem"}}>
                {("Already have an account? " if isSignup else "Don't have an account? ")}
                <span
                    onClick={onToggleMode}
                    style={{"color": "#111827", "cursor": "pointer", "fontWeight": "700"}}
                >
                    {("Log In" if isSignup else "Sign Up")}
                </span>
            </p>
        </div>;
}