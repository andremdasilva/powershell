
# URL to fetch the Zoom meeting IP ranges
$url = "https://assets.zoom.us/docs/ipranges/ZoomMeetings.txt"

# Path to temporarily save the downloaded file
$tempFile = "$env:TEMP\ZoomMeetings.txt"

# Download the Zoom meeting IP ranges file
Invoke-WebRequest -Uri $url -OutFile $tempFile

# Check if the file exists and read the content
if (Test-Path -Path $tempFile) {
    $content = Get-Content -Path $tempFile

    # Loop through each line in the file
    foreach ($line in $content) {
        # Skip empty lines or comments (assuming they start with #)
        if ($line -and $line -notmatch "^#") {
            try {
                # Add a permanent route for each IP range
                # The IP range format might need to be adjusted based on the content
                # If the line represents an IP range in CIDR format (e.g., 192.168.0.0/24)
                $route = $line.Trim()
                Write-Host "Adding route: $route"
                
                # Add route to the routing table (use -NextHop to specify gateway if needed)
                # If no gateway is specified, Windows will use the default route
                New-NetRoute -DestinationPrefix $route -InterfaceIndex 1 -RouteMetric 256 -Persistent $true
            } catch {
                Write-Warning "Failed to add route for: $line"
            }
        }
    }
} else {
    Write-Error "Failed to download the file."
}
