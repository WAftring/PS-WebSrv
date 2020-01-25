param (
	[switch]$WriteToFile,
	[switch]$Verbose
)

$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$HtmlPath = "C:\Users\Will\Development\PS-Site\Html\"
function Log-Writer {
    param (
        [string]$Message="",
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

function Build-Response {
	param(
	[string]$Type,
	$Content,
	[int]$NumBytes
	)
	#Response format:
	
	 #Response      = Status-Line               ; Section 6.1
     #                  *(( general-header        ; Section 4.5
     #                   | response-header        ; Section 6.2
     #                   | entity-header ) CRLF)  ; Section 7.1
     #                  CRLF
     #                  [ message-body ]          ; Section 7.2
	 
	 #Example Response:
	 #HTTP/1.1 200 OK..
	 #Content-Type: text/plain..
	 #Date: Fri, 24 Jan 2020 14:35:02 GMT..
	 #Server: nginx..
	 #Content-Length: 0..
	 #Connection: keep-alive....
	 $Date = Get-Date -UFormat "%a, %d %b %Y %T"
	$Response = ""
	switch($Type) {
	
		"GET" { $Response = "HTTP/1.1 200 OK`n"}
	}
	# We can flesh this out for different types
	$Response += "Content-Type: text/html;charset=UTF-8`n"
	$Response += "Date: $Date GMT`n"
	$Response += "Server: PowerShell`n"
	$Response += "Content-Length: $NumBytes`n`n"
	$Response += $(Get-Content $Content)
	
	return $Response
	

}
function Match-Uri {
	param(
	[string]$Uri=""
	)
	
	if($Uri -eq "/") {
		return $(Get-Item $($HtmlPath + "index.html"))
	}
	
	Get-ChildItem $HtmlPath | ForEach-Object {
		if($_.Name -eq $Uri.SubString(1)) {
			return $(Get-Item $_.FullName)
		}
	}

}

function Parse-HTTP {
    param(
        $Bytes,
        [int]$BytesRead
    )
    #Example Request text
	
	#GET / HTTP/1.1
	#Host: localhost:12345
	#Connection: keep-alive
	#Upgrade-Insecure-Requests: 1
	#User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36 Edg/79.0.309.71
	#Sec-Fetch-User: ?1
	#Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
	#Sec-Fetch-Site: none
	#Sec-Fetch-Mode: navigate
	#Accept-Encoding: gzip, deflate, br
	#Accept-Language: en-US,en;q=0.9
	
	$Type = ""
    $DecodedBytes = [System.Text.Encoding]::ASCII.GetString($Bytes, 0, $BytesRead)
    Log-Writer -Message "HTTP Request:`n`n$DecodedBytes" -Color "White"
    $DecodedBytes.Split("`n") | ForEach-Object {
        if ($_ -like "GET*") {
			$Type = "GET"
            $SplitRequest = $_.Split(" ")
			$Uri = $SplitRequest[1]
            }

		}
		
	return $Uri
    # This needs to be fleshed out to determine what is being asked for here...

}

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
	#while (($i = $TcpStream.Read($Bytes, 0, $Bytes.Length)) -ne 0)
	
	do 
    {
		$i = $TcpStream.Read($Bytes, 0, $Bytes.Length)
        #$Data = [System.Text.Encoding]::ASCII.GetString($Bytes, 0, $i)
        
        #Log-Writer -Message "Bytes received: $Bytes"
        #Log-Writer -Message "Data received: $Data"
		$Uri = Parse-HTTP -Bytes $Bytes -BytesRead $i
		$ContentItem = Match-Uri -Uri $Uri
		$Response = Build-Response -Type "GET" -Content $ContentItem -NumBytes $ContentItem.Length

        $Msg = [System.Text.Encoding]::ASCII.GetBytes($Response)
        $TcpStream.Write($Msg, 0, $Msg.Length)
		Log-Writer -Message "Data sent: $Response" 
		
    }while ($TcpStream.DataAvailable)
		
	
	$TcpClient.Close()
    
}
$TCPListener.Stop()
    




