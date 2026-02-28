"""InterviewerAI - Main Entry Point."""

# Tell the server to load our backend logic
sv {
    import from endpoints { SubmitInterview }
}

# Tell the client to load our frontend UI
cl {
    import from frontend { app as ClientApp }

    def:pub app {
        return <ClientApp />;
    }
}