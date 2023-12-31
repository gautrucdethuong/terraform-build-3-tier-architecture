# Terraform AWS Application Load Balancer (ALB)
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name               = "${local.name}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1]
  ]
  security_groups = [module.public_alb_sg.security_group_id]

  #   access_logs = {
  #     bucket = "my-alb-logs"
  #   }

  # Target Groups
  target_groups = [
    #App1 target group - TG Index = 0
    {
      name_prfix       = "app1-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      # App1 Target Group - Targets
      targets = {
        my_app1_vm1 = {
          target_id = module.ec2_private_app1.id[0]
          port      = 80
        },
        my_app1_vm2 = {
          target_id = module.ec2_private_app1.id[1]
          port      = 80
        }
      }
      tags = local.common_tags # Target Group Tags
    },

    # App2 Target Group - TG Index = 1
    {
      name_prefix          = "app2-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app2/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      # App2 Target Group - Targets
      targets = {
        my_app2_vm1 = {
          target_id = module.ec2_private_app2.id[0]
          port      = 80
        },
        my_app2_vm2 = {
          target_id = module.ec2_private_app2.id[1]
          port      = 80
        }
      }
      tags = local.common_tags # Target Group Tags
    },

    # App3 Target Group - TG Index = 2
    {
      name_prefix          = "app3-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      stickiness = {
        enabled         = true
        cookie_duration = 86400
        type            = "lb_cookie"
      }
      protocol_version = "HTTP1"
      # App3 Target Group - Targets
      targets = {
        my_app3_vm1 = {
          target_id = module.ec2_private_app3.id[0]
          port      = 8080
        },
        my_app3_vm2 = {
          target_id = module.ec2_private_app3.id[1]
          port      = 8080
        }
      }
      tags = local.common_tags # Target Group Tags
    }
  ]

  # Listeners
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      # target_group_index = 0 # App1 TG associated to this listener
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  # HTTPS Listener
  https_listeners = [
    # HTTPS Listener Index = 0 for HTTPS 443
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = 200
      }
    },
  ]
  # HTTPS Listener Rules
  https_listener_rules = [
    # Rule-1: /app1* should go to App1 EC2 Instances
    {
      https_listener_index = 0
      priority             = 1
      actions = [{
          type               = "forward"
          target_group_index = 0
        }]
      conditions = [{
        path_patterns = ["/app1*"]
      }]
    },
    # Rule-2: /app2* should go to App2 EC2 Instances    
    {
      https_listener_index = 0
      priority             = 2
      actions = [{
          type               = "forward"
          target_group_index = 1
        }]
      conditions = [{
        path_patterns = ["/app2*"] # Rule-2: /app2* should go to App2 EC2 Instances    
      }]
    },
    # Rule-3: /* should go to App3 - User-mgmt-WebApp EC2 Instances    
    {
      https_listener_index = 0
      priority             = 3
      actions = [{
        type               = "forward"
        target_group_index = 2
      }]
      conditions = [{
        path_patterns = ["/*"]
      }]
    },
  ]

  tags = local.common_tags # ALB Tags
}


