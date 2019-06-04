$drives = " C" #Which drive do you want to monitor e.g. D
$minSize = 1GB; #When to trigger the email alert.
 
#This script was created  by Tom Bindloss - 2019
#You're free to use this script however you please.
# You can find more of my scripts here - https://github.com/TomBindloss    

$email_username = "Exchange Login";
$email_password = "Exchange Password";
$email_smtp_host = "yourdomain.mail.protection.outlook.com";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "Sending address";
$email_to_addressArray = @("Address to alert 1","Address 2");  
if ($drives -eq $null -Or $drives -lt 1) {
  $localVolumes = Get-WMIObject win32_volume;
  $drives = @();
    foreach ($vol in $localVolumes) {
      if ($vol.DriveType -eq 3 -And $vol.DriveLetter -ne $null ) {
          $drives += $vol.DriveLetter[0];
    }
  }
}
foreach ($d in $drives) {
  Write-Host ("`r`n");
  Write-Host ("Checking drive " + $d + " ...");
  $disk = Get-PSDrive $d;
  if ($disk.Free -lt $minSize) {
    Write-Host ("Drive " + $d + " has less than " + $minSize `
      + " bytes free (" + $disk.free + "): sending e-mail...");
    
    $message = new-object Net.Mail.MailMessage;
    $message.From = $email_from_address;
    foreach ($to in $email_to_addressArray) {
      $message.To.Add($to);
    }
    $message.Subject =   ("ALERT!: " + $env:computername + " drive " + $d);
    $message.Subject +=  (" has less than " + $minSize + " bytes free ");
    $message.Subject +=  ("(" + $disk.Free + ")");
    $message.Body +=   "--------------------------------------------------------------";
    $message.Body +=  "`r`n";
    $message.Body +=   ("Machine HostName: " + $env:computername + " `r`n");
    {
    }
    $message.Body +=   ("Used space on drive " + $d + ": " + $disk.Used + " bytes. `r`n");
    $message.Body +=   ("Free space on drive " + $d + ": " + $disk.Free + " bytes. `r`n");
    $message.Body +=   "--------------------------------------------------------------";
    $smtp = new-object Net.Mail.SmtpClient($email_smtp_host, $email_smtp_port);
    $smtp.EnableSSL = $email_smtp_SSL;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($email_username, $email_password);
    $smtp.send($message);
    $message.Dispose();
    write-host "... E-Mail sent!" ; 
  }
  else {
    Write-Host ("Drive " + $d + " has more than " + $minSize + " bytes free: nothing to do.");
  }
}

exit
