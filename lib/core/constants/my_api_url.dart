class MyApiUrl {
  static const String baseUrl = "https://op-media-backend.up.railway.app";
  static const String version = "v1";

  static const String dashboard = "dashboard";

  // admin proposal
  static const String adminProposals = "proposals";
  static const String adminProposalsSummary = "proposals/summary";
  static String adminProposalById(String id) => "proposals/$id";
  static const String adminProposalGenerate = "proposals/generate";
}
