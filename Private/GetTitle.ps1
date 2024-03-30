function GetTitle([string]$Content)
{
    $Content | pup '.bg-blue text{}' --plain
}