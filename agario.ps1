param($squareAmount)
Add-Type -Path '.\engine.dll'

$engine = New-Object engine.Functions 

$w= 600
$h = 500

$engine.CreateWindow($w,$h,"agario")

#[Raylib_cs.Sound]$sound = $engine.LoadSoundFromFile("assets\sounds\sfx.wav")

if($null -eq $squareAmount)
{
    $squareAmount = 500
}

$helpplayer = @{
    velX = 0
    velY = 0
    size = 2
}
$player = [engine.Rectangle2D]::GetNew(0,0,20*$helpplayer.size,20*$helpplayer.size,250,0,0,250)

[System.Collections.ArrayList]$squares = @()



for ($i = 0; $i -lt $squareAmount; $i++) {
    $engine.DrawFrame();
    $engine.ClearFrameBackground();
    $engine.DrawText("Loading squares: $i/$squareAmount",20,$w/2,$h/2)
    $engine.ClearFrame();
    if($engine.IsAskingToCloseWindow()){
        break
        $engine.CloseWindow();
    }

    Write-Progress -Activity "Creating squares" -Status "$i/$squareAmount"
    $tam = (5..300 | Get-Random)
    $null = $squares.Add([engine.Rectangle2D]::GetNew((-3000..3000 | Get-Random),(-3000..3000 | Get-Random),$tam,$tam,(0..250 | Get-Random),(0..250 | Get-Random),(0..250 | Get-Random),250))   
}

$cam = [engine.Cam2D]::GetNew($engine.GetNewVector2($player.PosX,$player.PosY), $engine.GetNewVector2(300,200),$zoom,0)

$cam.UpdateOffset($w/2,$h/2)

$cam.UpdateZoom(1)
$cam.UpdateRotation(0)
Write-Host $squares.Count

[System.Collections.ArrayList]$circles = @() #[engine.Ball2D]::GetNew($w/2,$h/2,1,0,0,0,250)

for ($i = 200; $i -gt 0; $i--) { #create circles
    #list.add returns list.count to null
    $null = $circles.Add([engine.Ball2D]::GetNew(0,0,$i*100,0,0,0,80))
}

while(!$engine.IsAskingToCloseWindow()) {#main loop
    Start-Sleep -Milliseconds 20

    $p = $engine.GetNewVector2($player.PosX+$player.largura/2,$player.PosY+$player.altura/2)

    if($cam.camera.zoom -lt 0.3) {$cam.UpdateZoom(0.3)}
    
    $cam.UpdateTarget($p)

    $engine.DrawFrame();

    if($engine.IsHoldingKey('a')){
        $helpplayer.velX = -5
    }
    elseif($engine.IsHoldingKey('d'))
    {
        $helpplayer.velX = 5
    }
    else {
        $helpplayer.velX = 0
    }

    if ($engine.IsHoldingKey('w')) {
        $helpplayer.velY = -5
    }elseif ($engine.IsHoldingKey('s')) {
        $helpplayer.velY = 5
        
    }
    else {
        $helpplayer.velY = 0
    }

    $engine.StartMode2D($cam)

    foreach($b in $circles)
    {
        $b.DrawLine()
    }

    foreach($square in $squares)
    {
        $square.Draw()
        if($square.IsCollidingWithRectangle2D($player) -and $player.altura -gt $square.altura)
        {
            $helpplayer.size += 0.1

            $cam.UpdateZoom($cam.camera.zoom-0.1)

            $player = [engine.Rectangle2D]::GetNew($player.PosX,$player.PosY,20*$helpplayer.size,20*$helpplayer.size,250,0,0,250)
              
            $squares.Remove($square)

            $s = "agario " + ($squareAmount-$squares.Count) + "/$squareAmount"

            $engine.SetTitleWindow($s)
            
            break
            
        }
        
    }

    $player.Draw()
    $player.Move($helpplayer.velX,$helpplayer.velY)

    $engine.ClearFrameBackground();
    $engine.FinishMode2D()

    [Raylib_cs.Raylib]::DrawFPS(0,0)

    $engine.ClearFrame();
}

$engine.CloseWindow();
