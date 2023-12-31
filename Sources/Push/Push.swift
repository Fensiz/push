import ArgumentParser
import Foundation
import SWXMLHash
import Yams
import Logging


struct Stand {
	let name: String
	let domainName: String
}

enum Stands: String {
	case dev = "dev"
	case ift = "ift"
	func getAPI() -> Stand {
		switch self {
		case .dev:
			return Stand(name: "dev",
						 domainName: "-")
		case .ift:
			return Stand(name: "ift",
						 domainName: "-")
			
		}
	}
}

@main
public struct Push: ParsableCommand, AsyncParsableCommand {
	public init() {
		
	}
	
	public var text = "Hello, World!"
	
	@Option(help: "Product name")
	var product: String? = nil
	
	@Option(help: "Well")
	var well: String? = nil
	
	@Option(help: "Stand name")
	var stand: String? = nil
	
	@Option(help: "Logical Environment Prefix (ds20)")
	var le: String = ""
	
//	public func validate() throws {
//		guard product != nil else {
//			throw ValidationError("'<product>' must be set.")
//		}
//		guard stand != nil && Stands(rawValue: stand!) != nil else {
//			throw ValidationError("'<stand>' must be set.")
//		}
//	}
	

	public func run() async {
		
//		let url = URL(string: "https://www.w3schools.com/xml/simple.xml")!
//		let result = try! await URLSession.shared.data(from: url)
//		let x = String(decoding: result.0, as: UTF8.self)

		
		
		let url = FileManager.default
			.homeDirectoryForCurrentUser
			.appendingPathComponent("Downloads")
			.appendingPathComponent("simple")
			.appendingPathExtension("xml")
		let yaml = FileManager.default
			.homeDirectoryForCurrentUser
			.appendingPathComponent("Downloads")
			.appendingPathComponent("verify_apache")
			.appendingPathExtension("yaml")
		
		
		guard let x = try? String(contentsOf: url, encoding: .utf8) else { return }
		var xml = XMLHash.parse(x)
		print(">>\(xml["breakfast_menu"].children[0]["name"].element?.text ?? "")<<<")
//		xml["root"]["catalog"]
		guard let y = try? String(contentsOf: yaml, encoding: .utf8) else { return }
		let node = (try! Yams.load(yaml: y))!
		print((node as! [[AnyHashable:Any]])[0]["remote_user"] ?? "" )
		
		do {
			print("+++")
			Run.host = "vm-deb.local"
//			let x = try await Run.ssh("echo foo 1>&2")
			let x = try await Run.ssh("ls -l")
			print(">\(x.0 ?? "") \(x.1)<")
//			let y = try shell(<#T##command: String##String#>)
			
		} catch let error {
			print(error.localizedDescription)
		}
		let s = readLine()
	

//		print(template)
//		let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("\(productName.replacingOccurrences(of: "-", with: "_").lowercased())_\(stand.name3)\(logical_env_postfix)").appendingPathExtension("txt")
//		do {
//			try template.write(to: url, atomically: true, encoding: String.Encoding.utf8)
//		} catch {
//			print(error)
//		}
	}


}

class Run {
	enum RunError: Error {
	  case hostNotSet
	}
	static var logger = {
		var log = Logger(label: "Run")
		log.logLevel = .warning
		return log
	}()
	static var host: String? = nil
	
	static func scp(_ command: String) async throws -> (String?, Int32)  {
		guard let host = self.host else {
			throw RunError.hostNotSet
		}
		return try await shell("ssh \(host) \"\(command)\"")
	}
	
	static func ssh(_ command: String) async throws -> (String?, Int32)  {
		guard let host = self.host else {
			throw RunError.hostNotSet
		}
		return try await shell("ssh \(host) \"\(command)\"")
	}
	
	static func shell(_ command: String) async throws -> (String?, Int32)  {
		let task = Process()
		let outPipe = Pipe()
		let errPipe = Pipe()
		
		task.standardOutput = outPipe
		task.standardError = errPipe
		task.arguments = ["-c", command]
		task.launchPath = "/bin/zsh"
		task.standardInput = nil
		try task.run()
		let check = Task {
			logger.trace("check: start")
//			let progressBar = Task {
//				print("[", terminator: "")
//				defer { print("]") }
//				while true {
//					print("*", terminator: "")
//					try await Task.sleep(until: .now + .seconds(0.1), clock: .continuous)
//				}
//			}
//			defer {
//				progressBar.cancel()
//				
////				print("defered")
//				
//			}
			try await Task.sleep(until: .now + .seconds(5), clock: .continuous)
			
			if task.isRunning {
				task.terminate()
				logger.info("`\(command)` terminated")
			}
			logger.trace("check: finish")
		}
		
//		DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//			if task.isRunning {
//				task.terminate()
//				print("`\(command)` terminated")
//			}
//		}
		task.waitUntilExit()
		check.cancel()
		let status = task.terminationStatus
		
		let data = outPipe.fileHandleForReading.readDataToEndOfFile()
		let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
//		guard let data = data else { return (nil, status)}
		
		let output = String(data: data, encoding: .utf8)!
//		if let errData = errData {
			let error = String(data: errData, encoding: .utf8)!
		if !error.isEmpty {
			logger.error("stderr: #\(error)#")
		}
		logger.trace("stdout: $\(output)$")
//			print("error")
//		}
		return (output, status)
	}
}
