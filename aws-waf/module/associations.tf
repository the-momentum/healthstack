resource "aws_wafv2_web_acl_association" "this" {
  count = var.target_arn != "" ? 1 : 0

  resource_arn = var.target_arn
  web_acl_arn  = aws_wafv2_web_acl.this[count.index].arn

  depends_on = [aws_wafv2_web_acl.this]
}