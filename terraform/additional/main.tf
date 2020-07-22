resource "random_id" "server" {
    keepers = {
        name = "test1"
    }
  byte_length = 8
}

resource "azurerm_template_deployment" "example" {
  name                = random_id.server.hex
  resource_group_name = var.resource_group_name

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "sqlAdministratorLogin": {
            "type": "string",
            "metadata": {
                "description": "The admin user of the SQL Server"
            }
        },
        "sqlAdministratorLoginPassword": {
            "type": "securestring",
            "metadata": {
                "description": "The password of the admin user of the SQL Server"
            }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "Location for all resources."
            }
        }
    },
    "functions": [],
    "variables": {
        "sql-server-name": "arm-demo-server-xxx",
        "sql-db-name": "arm-demo-db",
        "app-plan-name": "arm-demo-app-plan",
        "app-name": "arm-demo-app-xxx"
    },
    "resources": [
        {
            "name": "[variables('sql-server-name')]",
            "type": "Microsoft.Sql/servers",
            "apiVersion": "2014-04-01",
            "location": "[parameters('location')]",
            "tags": {
                "displayName": "[variables('sql-server-name')]"
            },
            "properties": {
                "administratorLogin": "[parameters('sqlAdministratorLogin')]",
                "administratorLoginPassword": "[parameters('sqlAdministratorLoginPassword')]"
            },
            "resources": [
                {
                    "type": "firewallRules",
                    "apiVersion": "2014-04-01",
                    "dependsOn": [
                        "[variables('sql-server-name')]"
                    ],
                    "location": "[parameters('location')]",
                    "name": "AllowAllWindowsAzureIps",
                    "properties": {
                        "startIpAddress": "0.0.0.0",
                        "endIpAddress": "0.0.0.0"
                    }
                },
                {
                    "name": "[variables('sql-db-name')]",
                    "type": "databases",
                    "apiVersion": "2014-04-01",
                    "location": "[parameters('location')]",
                    "tags": {
                        "displayName": "[variables('sql-db-name')]"
                    },
                    "dependsOn": [ "[variables('sql-server-name')]" ],
                    "properties": {
                        "collation": "SQL_Latin1_General_CP1_CI_AS",
                        "edition": "Basic",
                        "maxSizeBytes": "1073741824",
                        "requestedServiceObjectiveName": "Basic"
                    }
                }
            ]
        },
        {
            "name": "[variables('app-plan-name')]",
            "type": "Microsoft.Web/serverfarms",
            "apiVersion": "2018-02-01",
            "location": "[parameters('location')]",
            "sku": {
                "name": "F1",
                "capacity": 1
            },
            "tags": {
                "displayName": "[variables('app-plan-name')]"
            },
            "properties": {
                "name": "[variables('app-plan-name')]"
            }
        },
        {
            "name": "[variables('app-name')]",
            "type": "Microsoft.Web/sites",
            "apiVersion": "2018-11-01",
            "location": "[parameters('location')]",
            "tags": {
                "[concat('hidden-related:', resourceGroup().id, '/providers/Microsoft.Web/serverfarms/', variables('app-plan-name'))]": "Resource",
                "displayName": "[variables('app-name')]"
            },
            "dependsOn": [
                "[resourceId('Microsoft.Web/serverfarms', variables('app-plan-name'))]"
            ],
            "properties": {
                "name": "[variables('app-name')]",
                "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', variables('app-plan-name'))]"
            },
            "resources": [
                {
                    "apiVersion": "2018-02-01",
                    "type": "config",
                    "name": "connectionstrings",
                    "dependsOn": [
                        "[variables('app-name')]"
                    ],
                    "properties": {
                        "DefaultConnection": {
                            "value": "[concat('Data Source=tcp:', reference(concat('Microsoft.Sql/servers/', variables('sql-server-name'))).fullyQualifiedDomainName, ',1433;Initial Catalog=', variables('sql-db-name'), ';User Id=', parameters('sqlAdministratorLogin'), '@', reference(concat('Microsoft.Sql/servers/', variables('sql-server-name'))).fullyQualifiedDomainName, ';Password=', parameters('sqlAdministratorLoginPassword'), ';')]",
                            "type": "SQLAzure"
                        }
                    }
                }
            ]
        }
    ],
    "outputs": {}
}
  DEPLOY

  parameters = {
    "sqlAdministratorLogin" = "123dasfd"
    "sqlAdministratorLoginPassword" = "Test12345"
  }

  deployment_mode = "Incremental"
}