# ============================================
# Azure Resource Expiry Checker
# ============================================

# CSV file path
$CsvPath = "C:\Vikram\Pipeline\Pipe line prctice-01-sep\Azure-Resource-Health-Expiry-Checker\Book1.csv"

# Slack Webhook URL
# Yahan apna actual Slack Webhook URL paste karo

##secrets ko remove kiya.
$webhookUrl = $env:SLACK_WEBHOOK_URL

# Get today's date
$Today = Get-Date

Write-Host ""
Write-Host "========================================"
Write-Host "       RESOURCE EXPIRY CHECKER"
Write-Host "========================================"
Write-Host "Today: $($Today.ToString('dd-MMM-yyyy'))"
Write-Host ""

# Check if CSV file exists
if (-not (Test-Path $CsvPath)) {
    Write-Host "ERROR: resources.csv file not found." -ForegroundColor Red
    exit
}

# Read CSV file
$Resources = Import-Csv -Path $CsvPath

# Find resources whose expiry date is before today
$ExpiredResources = @(
    $Resources | Where-Object {
        [datetime]$_.ExpiryDate -lt $Today.Date
    }
)

# Check if expired resources exist
if ($ExpiredResources.Count -eq 0) {

    Write-Host "No expired resources found." -ForegroundColor Green

    exit
}

# Display heading
Write-Host ""
Write-Host "Expired resource" -ForegroundColor Red
Write-Host "=================" -ForegroundColor Red
Write-Host ""

# Slack message
$SlackMessage = "*Expired resource*`n`n"

# Process every expired resource
foreach ($Resource in $ExpiredResources) {

    $ExpiryDate = ([datetime]$Resource.ExpiryDate).ToString("dd-MMM-yyyy")

    # Display in PowerShell
    Write-Host "resource name : $($Resource.ResourceName)"
    Write-Host "Owner         : $($Resource.Owner)"
    Write-Host "Environment   : $($Resource.Environment)"
    Write-Host "Expiry date   : $ExpiryDate"
    Write-Host ""

    # Add details to Slack message
    $SlackMessage += "*resource name :* $($Resource.ResourceName)`n"
    $SlackMessage += "*Owner :* $($Resource.Owner)`n"
    $SlackMessage += "*Environment :* $($Resource.Environment)`n"
    $SlackMessage += "*Expiry date :* $ExpiryDate`n"
    $SlackMessage += "`n"
}

# ============================================
# Send notification to Slack
# ============================================

# Check whether Slack Webhook URL has been configured
if ($SlackWebhookUrl -eq "YOUR_SLACK_WEBHOOK_URL") {

    Write-Host "WARNING: Slack Webhook URL is not configured." -ForegroundColor Yellow
    Write-Host "PowerShell report generated successfully."
    exit
}

# Create Slack JSON payload
$Payload = @{
    text = $SlackMessage
} | ConvertTo-Json

# Send message to Slack
try {

    Invoke-RestMethod `
        -Uri $SlackWebhookUrl `
        -Method Post `
        -ContentType "application/json" `
        -Body $Payload

    Write-Host "Slack notification sent successfully." -ForegroundColor Green

}
catch {

    Write-Host "ERROR: Failed to send Slack notification." -ForegroundColor Red
    Write-Host $_.Exception.Message
}