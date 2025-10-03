# Generate commits from Jan 30, 2016 to Oct 3, 2025
# Pattern: Random days with different commit counts per year

# Set location to git repository
Set-Location "c:\Users\rites\Desktop\New folder (10)\private"

# Initialize git if not already done
if (!(Test-Path ".git")) {
    git init
    git remote add origin https://github.com/ritesh-chauhan0x1/private.git  # Replace with your repo URL
}

# Create a simple file to modify
if (!(Test-Path "activity.txt")) {
    "Initial file content" | Out-File -FilePath "activity.txt" -Encoding UTF8
    git add activity.txt
    git commit -m "Initial commit"
}

# Function to generate random date in a year
function Get-RandomDateInYear {
    param([int]$year)
    $startDate = Get-Date -Year $year -Month 1 -Day 1
    $endDate = Get-Date -Year $year -Month 12 -Day 31
    $randomDays = Get-Random -Minimum 0 -Maximum (($endDate - $startDate).Days + 1)
    return $startDate.AddDays($randomDays)
}

# Function to create commit with specific date
function Create-CommitWithDate {
    param(
        [DateTime]$date,
        [string]$message,
        [int]$lineNumber = 1
    )
    
    $dateString = $date.ToString("ddd MMM dd HH:mm:ss yyyy +0530")
    $env:GIT_AUTHOR_DATE = $dateString
    $env:GIT_COMMITTER_DATE = $dateString
    
    # Modify a line in the file
    $content = Get-Content "activity.txt" -ErrorAction SilentlyContinue
    if (!$content) { $content = @() }
    
    # Ensure we have enough lines
    while ($content.Count -lt $lineNumber) {
        $content += "Line $($content.Count + 1)"
    }
    
    # Modify the specified line
    $content[$lineNumber - 1] = "Modified at $($date.ToString('yyyy-MM-dd HH:mm:ss')) - $message"
    
    $content | Out-File -FilePath "activity.txt" -Encoding UTF8
    git add activity.txt
    git commit --allow-empty -m $message
}

# Function to push commits monthly
function Push-Monthly {
    param([DateTime]$date)
    Write-Host "Pushing commits for $($date.ToString('MMMM yyyy'))..." -ForegroundColor Green
    try {
        git push origin main --force
        Write-Host "Successfully pushed commits for $($date.ToString('MMMM yyyy'))" -ForegroundColor Green
    } catch {
        Write-Host "Failed to push commits for $($date.ToString('MMMM yyyy')): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Generate commits for each year from 2016 to 2025
$startYear = 2016
$endYear = 2025
$commitCounter = 1

for ($year = $startYear; $year -le $endYear; $year++) {
    Write-Host "Processing year $year..." -ForegroundColor Yellow
    
    # Skip if year is 2016 and we start from Jan 30
    $yearStartDate = if ($year -eq 2016) { Get-Date -Year 2016 -Month 1 -Day 30 } else { Get-Date -Year $year -Month 1 -Day 1 }
    # End at Oct 3, 2025 if it's 2025
    $yearEndDate = if ($year -eq 2025) { Get-Date -Year 2025 -Month 10 -Day 3 } else { Get-Date -Year $year -Month 12 -Day 31 }
    
    # Get all possible dates for this year
    $allDates = @()
    $currentDate = $yearStartDate
    while ($currentDate -le $yearEndDate) {
        $allDates += $currentDate
        $currentDate = $currentDate.AddDays(1)
    }
    
    # Shuffle dates and select patterns
    $shuffledDates = $allDates | Sort-Object {Get-Random}
    
    # Pattern 1: 100 random days with 6 commits each (or available days if less than 100)
    $pattern1Count = [Math]::Min(100, $shuffledDates.Count)
    $pattern1Dates = $shuffledDates[0..($pattern1Count - 1)]
    $remainingDates = $shuffledDates[$pattern1Count..($shuffledDates.Count - 1)]
    
    # Pattern 2: 2 random days with 20 commits each
    $pattern2Count = [Math]::Min(2, $remainingDates.Count)
    $pattern2Dates = if ($pattern2Count -gt 0) { $remainingDates[0..($pattern2Count - 1)] } else { @() }
    $remainingDates = if ($pattern2Count -gt 0) { $remainingDates[$pattern2Count..($remainingDates.Count - 1)] } else { $remainingDates }
    
    # Pattern 3: 100 random days with 3-5 commits each (or available days)
    $pattern3Count = [Math]::Min(100, $remainingDates.Count)
    $pattern3Dates = if ($pattern3Count -gt 0) { $remainingDates[0..($pattern3Count - 1)] } else { @() }
    $remainingDates = if ($pattern3Count -gt 0) { $remainingDates[$pattern3Count..($remainingDates.Count - 1)] } else { $remainingDates }
    
    # Pattern 4: 50 random days with 1 commit each (or available days)
    $pattern4Count = [Math]::Min(50, $remainingDates.Count)
    $pattern4Dates = if ($pattern4Count -gt 0) { $remainingDates[0..($pattern4Count - 1)] } else { @() }
    
    $lastPushMonth = 0
    
    # Process Pattern 1: 6 commits per day
    foreach ($date in $pattern1Dates) {
        for ($i = 1; $i -le 6; $i++) {
            $commitTime = $date.AddHours((Get-Random -Minimum 0 -Maximum 24)).AddMinutes((Get-Random -Minimum 0 -Maximum 60))
            $message = "Daily activity commit #$i for $($date.ToString('MMMM dd, yyyy')) (Commit #$commitCounter)"
            Create-CommitWithDate -date $commitTime -message $message -lineNumber (($commitCounter % 10) + 1)
            $commitCounter++
        }
        
        # Push monthly
        if ($date.Month -ne $lastPushMonth) {
            Push-Monthly -date $date
            $lastPushMonth = $date.Month
            Start-Sleep -Seconds 2  # Brief pause between pushes
        }
    }
    
    # Process Pattern 2: 20 commits per day
    foreach ($date in $pattern2Dates) {
        for ($i = 1; $i -le 20; $i++) {
            $commitTime = $date.AddHours((Get-Random -Minimum 0 -Maximum 24)).AddMinutes((Get-Random -Minimum 0 -Maximum 60))
            $message = "Heavy development day commit #$i for $($date.ToString('MMMM dd, yyyy')) (Commit #$commitCounter)"
            Create-CommitWithDate -date $commitTime -message $message -lineNumber (($commitCounter % 10) + 1)
            $commitCounter++
        }
        
        # Push monthly
        if ($date.Month -ne $lastPushMonth) {
            Push-Monthly -date $date
            $lastPushMonth = $date.Month
            Start-Sleep -Seconds 2
        }
    }
    
    # Process Pattern 3: 3-5 commits per day
    foreach ($date in $pattern3Dates) {
        $commitsToday = Get-Random -Minimum 3 -Maximum 6
        for ($i = 1; $i -le $commitsToday; $i++) {
            $commitTime = $date.AddHours((Get-Random -Minimum 0 -Maximum 24)).AddMinutes((Get-Random -Minimum 0 -Maximum 60))
            $message = "Regular development commit #$i for $($date.ToString('MMMM dd, yyyy')) (Commit #$commitCounter)"
            Create-CommitWithDate -date $commitTime -message $message -lineNumber (($commitCounter % 10) + 1)
            $commitCounter++
        }
        
        # Push monthly
        if ($date.Month -ne $lastPushMonth) {
            Push-Monthly -date $date
            $lastPushMonth = $date.Month
            Start-Sleep -Seconds 2
        }
    }
    
    # Process Pattern 4: 1 commit per day
    foreach ($date in $pattern4Dates) {
        $commitTime = $date.AddHours((Get-Random -Minimum 0 -Maximum 24)).AddMinutes((Get-Random -Minimum 0 -Maximum 60))
        $message = "Minor update for $($date.ToString('MMMM dd, yyyy')) (Commit #$commitCounter)"
        Create-CommitWithDate -date $commitTime -message $message -lineNumber (($commitCounter % 10) + 1)
        $commitCounter++
        
        # Push monthly
        if ($date.Month -ne $lastPushMonth) {
            Push-Monthly -date $date
            $lastPushMonth = $date.Month
            Start-Sleep -Seconds 2
        }
    }
    
    Write-Host "Completed year $year with $(($pattern1Dates.Count * 6) + ($pattern2Dates.Count * 20) + ($pattern3Dates | ForEach-Object { Get-Random -Minimum 3 -Maximum 6 } | Measure-Object -Sum).Sum + $pattern4Dates.Count) commits" -ForegroundColor Green
}

# Final push to ensure all commits are uploaded
Write-Host "Performing final push..." -ForegroundColor Cyan
git push origin main --force

Write-Host "All commits generated and pushed successfully!" -ForegroundColor Green
Write-Host "Total commits created: $($commitCounter - 1)" -ForegroundColor Green

# Clean up environment variables
Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue