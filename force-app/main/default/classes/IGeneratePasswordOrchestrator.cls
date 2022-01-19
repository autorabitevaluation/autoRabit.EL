public interface IGeneratePasswordOrchestrator {
    DateTime GetExpirationDate();
    String AutoGeneratePassword();
}