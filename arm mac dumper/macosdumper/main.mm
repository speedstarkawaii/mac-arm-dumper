
#include <fstream>
#include <iostream>
#include <regex>
#include <string>
#include <vector>

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

/*
 
 this is pretty much a assembly lookup dumper lol (but a better one cus ik i did another one before this it was for intel mac)
 works by reading otools file that it dumps
 100% reliable and ud
 
 by @speedthescientist
 
 PS i added some calls from rbx::printidentity :c to help u a bit
 
 i included a file in the github that gives a explanation on how to add more
 mogs  capstone or wtv non-window ppl use
 */

// config?
const std::string asmroot = "/Users/axml/Desktop/Roblox.asm"; // change to ur path to whatever or wherever otools made the file or user
static NSString *gay = @"yes me and u are gay";

size_t retnasmstart(
    const std::vector<std::string>& lines,
    size_t index)
{
    while (index > 0)
    {
        const std::string& line = lines[index];

        if (line.find("stp") != std::string::npos &&line.find("x29") != std::string::npos &&line.find("x30") != std::string::npos &&line.find("[sp") != std::string::npos)
        {
            return index;
        }

        --index;
    }

    return 0;
}

std::vector<std::string> retnasm(NSString *asmroot)
{
    NSError *error = nil;
    NSString *contents = [NSString stringWithContentsOfFile:asmroot
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    if (contents == nil) {
        return {};
    }

    NSArray<NSString *> *stringeslines =
        [contents componentsSeparatedByString:@"\n"];

    std::vector<std::string> lines;
    lines.reserve(stringeslines.count);

    for (NSString *line in stringeslines) {
        NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
        lines.emplace_back(
            static_cast<const char *>(data.bytes),
            data.length
        );
    }

    if (!lines.empty() && lines.back().empty()) {
        lines.pop_back();
    }

    return lines;
}

// everything from print identity (TECHNICALLY) i did miss the identity part but no one uses that shit anyways so if u want its the first one in printidentity
namespace printidentity {
std::string identitystringaaaaa = "Current identity is %d";

std::string standardoutprintf(const std::vector<std::string>& lines)
{
    std::regex instructionz(R"(\bbl\s+0x([0-9a-fA-F]+))");

    for (size_t i = 0; i < lines.size(); ++i)
    {
        if (lines[i].find(identitystringaaaaa) == std::string::npos)
            continue;

        for (size_t j = i + 1; j < lines.size(); ++j)
        {
            if (lines[j].empty() || lines[j].back() == ':')
                break;

            std::smatch got;
            if (std::regex_search(lines[j], got, instructionz))
                return got[1].str();
        }

        break;
    }

    return {};
}

std::string lua_gettop(const std::vector<std::string>& lines)
{
    const std::regex instructionz(R"(\bbl\s+0x([0-9a-fA-F]+))");
    
    for (size_t i = 0; i < lines.size(); ++i)
    {
        if (lines[i].find(identitystringaaaaa) == std::string::npos)
            continue;

        const size_t funstart = retnasmstart(lines, i);
        int calls = 0;

        for (size_t j = funstart; j < i; ++j)
        {
            std::smatch got;
            if (std::regex_search(lines[j], got, instructionz) && ++calls == 2)
                return got[1].str();
        }

        break;
    }

    return {};
}

std::string lua_tolstring(const std::vector<std::string>& lines)
{
    const std::regex instructionz(R"(\bbl\s+0x([0-9a-fA-F]+))");
    
    for (size_t i = 0; i < lines.size(); ++i)
    {
        if (lines[i].find(identitystringaaaaa) == std::string::npos)
            continue;

        const size_t funstart = retnasmstart(lines, i);
        int calls = 0;

        for (size_t j = funstart; j < i; ++j)
        {
            std::smatch got;
            if (std::regex_search(lines[j], got, instructionz) && ++calls == 3)
                return got[1].str();
        }

        break;
    }

    return {};
}
}

int main()
{
    auto timerr = std::chrono::steady_clock::now();
    
    auto now = std::chrono::system_clock::now();
    std::time_t time = std::chrono::system_clock::to_time_t(now);

    NSMutableString *output = [NSMutableString string];

    [output appendString:@"\n// @speedthescientist on Discord & YouTube\n"];

    char time_buffer[32];
    std::strftime(time_buffer, sizeof(time_buffer), "%Y-%m-%d %H:%M:%S", std::localtime(&time));
    [output appendFormat:@"// time stamp @ %s\n", time_buffer];

    [output appendString:@"// swap to macOS ARM64, was macOS x86_64\n\n"];
    
    NSString *asmroot = @"/Users/axml/Desktop/Roblox.asm";
    BOOL asmexis = [[NSFileManager defaultManager] fileExistsAtPath:asmroot];
    
    if (!asmexis) {
        NSLog(@"// open Terminal and paste ts:%@", @"otool -arch arm64 -tvV /Applications/Roblox.app/Contents/MacOS/RobloxPlayer > ~/Desktop/Roblox.asm");
        return 0;
    }
              
    [output appendString:@"\n"];

    auto niggasembly = retnasm(asmroot);

    //std::cout<< "// HEADER:0000000100000000\n";

    std::string printaddy = printidentity::standardoutprintf(niggasembly);
    std::string gettopaddy = printidentity::lua_gettop(niggasembly);
    std::string tolstringaddy = printidentity::lua_tolstring(niggasembly);
// dw it will take a while to scan i mean my shitis 800mbs so

   // if (printaddy.empty())
      //  std::cout << "uintptr_t RBXstandardout_printf = 0;\n";
 //   else
    [output appendFormat:@"uintptr_t print = 0x%s;\n", printaddy.c_str()];// did u mean printf? shit  xcode
    [output appendFormat:@"uintptr_t lua_gettop = 0x%s;\n", gettopaddy.c_str()];
    [output appendFormat:@"uintptr_t lua_tolstring = 0x%s;\n", tolstringaddy.c_str()];
    
    [output appendString:@"\n"];
    
    auto stopit = std::chrono::steady_clock::now();

    double stoppedwatch =
        std::chrono::duration<double>(stopit - timerr).count();
    
    [output appendString:@"///////////////////////////////////////////\n// WARNING: make sure to rebase these btw  \n"];

    [output appendFormat:@"\n// returned in (approx. %.6fs)\n\n", stoppedwatch];

    NSLog(@"%@", output);

    return 1;
}
