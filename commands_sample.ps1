$commands = @{
    kt = @{
        Title = "Run KT Connector"
        Command = {
            cd 'C:/software/kt connect'
            .\ktctl.exe connect --kubeconfig .\kube-new.config --debug --namespace dev
        }
    }

    mda = @{
        Title = "Run ZCAD Frontend"
        Command = {
            cd 'D:/projects/zixel/zcad/mda'
            pnpm run dev:pc
        }
    }

    ivy = @{
        Title = "Go to IVY Project directory"
        Command = {
            cd 'D:/projects/zixel/zcad/ivyproject'
        }
    }

    ivy2 = @{
        Title = "Go to IVY Project 2 directory"
        Command = {
            cd 'D:/projects/zixel/zcad/ivyproject_2'
        }
    }

    conan = @{
        Title = "Run Conan Install"
        Command = {
            conan install . --output-folder=build --build='*' --settings=build_type=Debug -r cpp-cad-group
        }
    }

    conan_m = @{
        Title = "Run Conan Install Missing"
        Command = {
            conan install . --output-folder=build --build=missing --settings=build_type=Debug -r cpp-cad-group
        }
    }
}
