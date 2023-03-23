module "rg_name" {
  source             = "github.com/ParisaMousavi/az-naming//rg?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "resourcegroup" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source   = "github.com/ParisaMousavi/az-resourcegroup?ref=2022.10.07"
  location = var.location
  name     = module.rg_name.result
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "spg_svc_name" {
  source             = "github.com/ParisaMousavi/az-naming//spg-svc?ref=main"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "spg_svc" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "github.com/ParisaMousavi/az-spg-svc?ref=main"
  location            = var.location
  name                = module.spg_svc_name.result
  resource_group_name = module.resourcegroup.name
  network = {
    app_subnet_id             = null
    service_runtime_subnet_id = null
    cidr_ranges               = null
  }
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "spg_app_name" {
  source             = "github.com/ParisaMousavi/az-naming//spg-app?ref=main"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  assembly           = "one"
  location_shortname = var.location_shortname
}

# module "spg_app_one" {
#   # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
#   source              = "github.com/ParisaMousavi/az-spg-app?ref=main"
#   name                = module.spg_svc_name.result
#   resource_group_name = module.resourcegroup.name
#   service_name        = module.spg_svc.name
# }

resource "azurerm_app_service_environment" "example" {
  name                         = "example-ase"
  resource_group_name          = module.resourcegroup.name
  subnet_id                    = data.terraform_remote_state.network.outputs.subnets["aad-aks"].id
  pricing_tier                 = "I2"
  front_end_scale_factor       = 10
  internal_load_balancing_mode = "Web, Publishing"
  # allowed_user_ip_cidrs        = ["11.22.33.44/32", "55.66.77.0/24"]

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }
}