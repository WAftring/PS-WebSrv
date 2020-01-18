$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Log-Writer {
    param (
        [string]$Message="",
        [bool]$WriteToFile=$false,
        [string]$Color="White"
    )
    $Timestamp = Get-Date -UFormat "%Y-%m-%d %H:%M:%S%Z"
    Write-Host "[$Timestamp`] $Message" -ForegroundColor $Color
    if ($WriteToFile) {
        if(!$(Test-Path -Path $($ModulePath + "SocketCore.log")))
        {
            New-Item -Path $($ModulePath + "SocketCore.log")
        }
        Add-Content -Path $($ModulePath + "SocketCore.log") -Value $Message
    }
}


$Content = Get-Content -Path C:\Users\Will\Development\PS-Site\PS-WebSrv\Sample.html
$Response = "HTTP/1.1 200 OK`nContent-Type: text/html`nContent-Length: 1200`n`n$Content"
$Port = 12345
$Bytes = [System.Byte[]]::new(2048)
Log-Writer -Message "Creating TCP listener on port: $Port"
$TCPListener = [System.Net.Sockets.TcpListener]12345
$TCPListener.Start()
Log-Writer -Message "TCP Listener created on local port $Port" -Color "Green"
while($true)
{
    Log-Writer -Message "Waiting for connection"
    $TcpClient = $TCPListener.AcceptTcpClient()
    Log-Writer -Message $("Client " + $TcpClient.Client.RemoteEndPoint + " connected") -Color "Green"

    $TcpStream = $TcpClient.GetStream()

    $i = 0
    $Data = ""
    while (($i = $TcpStream.Read($Bytes, 0, $Bytes.Length)) -ne 0)
    {
        $Data = [System.Text.Encoding]::ASCII.GetString($Bytes, 0, $i)
        Log-Writer -Message "Data received: $Data"

        $Data = $Data.ToUpper()

        $Msg = [System.Text.Encoding]::ASCII.GetBytes($Response)
        $TcpStream.Write($Msg, 0, $Msg.Length)
        Log-Writer -Message "Data sent: $Response" 
    }
    $TcpClient.Close()

    
}
$TCPListener.Stop()
    




