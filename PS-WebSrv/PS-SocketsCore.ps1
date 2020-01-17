
$Bytes = ""
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
        Write-Output "Received $Data"

        $Data = $Data.ToUpper()

        $Msg = [System.Text.Encoding]::ASCII.GetBytes("Hello World")
        $TcpStream.Write($Msg, 0, $Msg.Length)
        Write-Output "Sent $Data"
    }
    $TcpClient.Close()

    
}
$TCPListener.Stop()
    




