$Content = Get-Content -Path C:\Users\Will\Development\PS-Site\PS-WebSrv\Sample.html
$ContentLength = 
$Response = "HTTP/1.1 200 OK`nContent-Type: text/html`nContent-Length: 1200`n`n$Content"
$Bytes = [System.Byte[]]::new(2048)
$TCPListener = [System.Net.Sockets.TcpListener]12345
$TCPListener.Start()
while($true)
{
    Write-Output "Waiting for connection"
    $TcpClient = $TCPListener.AcceptTcpClient()
    Write-Output "Connected"

    $TcpStream = $TcpClient.GetStream()

    $i = 0
    $Data = ""
    while (($i = $TcpStream.Read($Bytes, 0, $Bytes.Length)) -ne 0)
    {
        $Data = [System.Text.Encoding]::ASCII.GetString($Bytes, 0, $i)
        Write-Output "Received `n$Data"

        $Data = $Data.ToUpper()

        $Msg = [System.Text.Encoding]::ASCII.GetBytes($Response)
        $TcpStream.Write($Msg, 0, $Msg.Length)
        Write-Output "Sent $Response"
    }
    $TcpClient.Close()

    
}
$TCPListener.Stop()
    




