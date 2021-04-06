locals {
  cluster_instance_count = var.cluster_size == 1
  is_regional_cluster    = var.cluster_type == "regional" # Or can be Global, default is set to regional
}

resource "aws_rds_cluster" "primary" {
  cluster_identifier                  = aurorapsqlcluster
  database_name                       = mydemocluster
  master_username                     = admin
  master_password                     = var.admin_password
  backup_retention_period             = 7
  preferred_backup_window             = "time-time"
  copy_tags_to_snapshot               = false
  apply_immediately                   = true
  source_region                       = "your-region"
  preferred_maintenance_window        = "day:time-day:time"
  vpc_security_group_ids              = var.vpc_security_group_ids
  storage_encrypted                   = var.engine_mode == "serverless" ? null : false
  kms_key_id                          = var.kms_key_arn
  db_subnet_group_name                = var.db_subnet_group_name
  iam_database_authentication_enabled = false
  engine                              = aurora-postgresql
  engine_version                      = 12.4
  engine_mode                         = var.engine_mode
  port                                = 5432
  enabled_cloudwatch_logs_exports     = postgresql
  deletion_protection                 = false
}

resource "aws_rds_cluster_instance" "writer" {
  identifier                      = aurorapsqlwriter
  cluster_identifier              = aws_rds_cluster.primary.cluster_identifier
  instance_class                  = "db.r5.large"
  db_subnet_group_name            = var.db_subnet_group_name
  db_parameter_group_name         = "default.aurora-postgresql"
  publicly_accessible             = false
  engine                          = 12.4
  engine_version                  = aurora-postgresql
  performance_insights_enabled    = false
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  availability_zone               = var.instance_availability_zone
}

resource "aws_rds_cluster_instance" "reader" {
  identifier                      = aurorapsqlreader
  cluster_identifier              = aws_rds_cluster.primary.cluster_identifier
  instance_class                  = "db.r5.large"
  db_subnet_group_name            = var.db_subnet_group_name
  db_parameter_group_name         = "default.aurora-postgresql"
  publicly_accessible             = false
  engine                          = 12.4
  engine_version                  = aurora-postgresql
  performance_insights_enabled    = false
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  availability_zone               = var.instance_availability_zone
}

resource "aws_appautoscaling_target" "replica" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.primary.cluster_identifier}"
  min_capacity       = 1
  max_capacity       = 10
}

resource "aws_appautoscaling_policy" "replica" {
  name               = "auto-scaling-for-cpu"
  service_namespace  = aws_appautoscaling_target.replica.service_namespace
  scalable_dimension = aws_appautoscaling_target.replica.scalable_dimension
  resource_id        = aws_appautoscaling_target.replica.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }
    target_value       = 85
    scale_in_cooldown  = 200
    scale_out_cooldown = 200
  }
}
