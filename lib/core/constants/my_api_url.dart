class MyApiUrl {
  static const String baseUrl = "https://op-media-backend.up.railway.app";
  static const String version = "v1";
  static const String googleAuth = "auth/google";

  static const String dashboard = "dashboard";

  // property
  static const String properties = "properties";
  static String propertyById(String id) => "properties/$id";

  // tenant
  static const String tenants = "tenants";
  static String tenantById(String id) => "tenants/$id";

  //employee
  static const String employees = "employees";

  //report
  static const String reports = "reports";

  //invoice
  static const String invoices = "invoices";

  // admin proposal
  static const String adminProposals = "proposals";
  static const String adminProposalsSummary = "proposals/summary";
  static String adminProposalById(String id) => "proposals/$id";
  static const String adminProposalGenerate = "proposals/generate";
}
