
# ============================================================
#  lambda.tf — removed (reports now served directly by backend)
#  Keeping only the data source needed by other resources.
# ============================================================

# ── Data source for account ID ────────────────────────────────
data "aws_caller_identity" "current" {}
