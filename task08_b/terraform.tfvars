# No overrides needed here if defaults in variables.tf match task parameters
# Ensure required non-defaulted variables (like git_pat if used) are set via environment or other means

# Example if overriding defaults was needed:
# name_prefix = "cmtr-49b8ddc2-mod8b"
# location    = "West Europe"
# creator     = "theodor-laurentiu_robescu@epam.com"
# acr_sku     = "Basic"
# aks_vm_size = "Standard_D2ads_v5"
# aks_os_disk_type = "Ephemeral"
