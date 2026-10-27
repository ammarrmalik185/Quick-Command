using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
[assembly: AssemblyTitle("Quick Command")]
[assembly: AssemblyProduct("Quick Command")]
[assembly: AssemblyVersion("1.0.1.0")]
[assembly: AssemblyFileVersion("1.0.1.0")]
class Launcher {
    [DllImport("kernel32.dll")] static extern uint GetConsoleProcessList(uint[] processes, uint count);
    static string Literal(string text) {
        return "([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('" + Convert.ToBase64String(Encoding.UTF8.GetBytes(text)) + "')))";
    }
    static int Main(string[] args) {
        int result = 1;
        try {
            string script = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "qc.ps1");
            StringBuilder code = new StringBuilder("$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; try { $global:LASTEXITCODE=0; & ");
            code.Append(Literal(script));
            if (args.Length > 0) {
                code.Append(" -commandName ").Append(Literal(args[0]));
                if (args.Length > 1) {
                    code.Append(" -CommandArguments @(");
                    for (int i = 1; i < args.Length; i++) { if (i > 1) code.Append(','); code.Append(Literal(args[i])); }
                    code.Append(')');
                }
            }
            code.Append("; if ($LASTEXITCODE) { exit $LASTEXITCODE }; exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }");
            string ps = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), @"WindowsPowerShell\v1.0\powershell.exe");
            // Apply only to this child session: clean Windows clients default to Restricted.
            // This does not change persistent settings or override organizational Group Policy.
            ProcessStartInfo info = new ProcessStartInfo(ps, "-NoLogo -NoProfile -ExecutionPolicy Bypass -File \"" + Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "launch.ps1") + "\" " + Convert.ToBase64String(Encoding.Unicode.GetBytes(code.ToString())));
            info.UseShellExecute = false;
            // Keep the invoking terminal's working directory and streams.
            using (Process child = Process.Start(info)) { child.WaitForExit(); result = child.ExitCode; }
        } catch (Exception e) { Console.Error.WriteLine(e.Message); }
        if (args.Length == 0 && !Console.IsInputRedirected && GetConsoleProcessList(new uint[2], 2) == 1) {
            Console.WriteLine("Press any key to close..."); Console.ReadKey(true);
        }
        return result;
    }
}


