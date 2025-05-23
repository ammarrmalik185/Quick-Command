@{
    	"hello" = @{
        	Title = "Say hello"
        	Command = " Write-Host 'Hello, world!' "
    	}
    	"datetime" = @{
        	Title = "Show current date/time"
        	Command = " Get-Date "
    	}
	"kt" = @{
        	Title = "Run KT Connector"
        	Command = " cd 'C:/software/kt connect' ; ./run "
    	}
	"mda" = @{
        	Title = "Run ZCAD Frontend"
        	Command = " cd 'D:/projects/zixel/zcad/mda'; pnpm run dev:pc "
    	}
	"ivy" = @{
        	Title = "Go to IVY Project directory"
        	Command = " cd 'D:/projects/zixel/zcad/ivyproject_2' "
    	}

}