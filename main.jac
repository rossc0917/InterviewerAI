"""InterviewerAI - Main Entry Point."""

cl {
    import from .frontend { app as ClientApp }

    def:pub app {
        return <ClientApp />;
    }
}