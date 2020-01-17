param (
    [string]$Search="localhost",
    [int]$Port=12345
)

$Server = "localhost"
$Port = 12345
$Bytes = [System.Byte[]]::new(2048)
$TcpClient = New-Object System.Net.Sockets.TcpClient $Server, $Port
$TcpStream = $TcpClient.GetStream()
Write-Output "Sending Hello World"
$Bytes = [System.Text.Encoding]::ASCII.GetBytes("Hello World")
$TcpClient.Client.Send($Bytes)

$i = 0
$Data = ""
while (($i = $TcpStream.Read($Bytes, 0, $Bytes.Length)) -ne 0) {
    $Data = [System.Text.Encoding]::ASCII.GetString($Bytes, 0, $i)
    Write-Output $Data
    break
}

$TcpClient.Close()
