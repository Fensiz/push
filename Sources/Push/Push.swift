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
	var product: String
	
	@Option(help: "Version")
	var version: String? = nil
	
	@Option(help: "Stand name")
	var user: String? = nil
	
	@Option(help: "Logical Environment Prefix (ds20)")
	var le: String? = nil
	
//	public func validate() throws {
//		guard product != nil else {
//			throw ValidationError("'<product>' must be set.")
//		}
//		guard stand != nil && Stands(rawValue: stand!) != nil else {
//			throw ValidationError("'<stand>' must be set.")
//		}
//	}
	public func yamlExample() {
		let yaml = FileManager.default
			.homeDirectoryForCurrentUser
			.appendingPathComponent("Downloads")
			.appendingPathComponent("verify_apache")
			.appendingPathExtension("yaml")
		guard let y = try? String(contentsOf: yaml, encoding: .utf8) else { return }
		let node = (try! Yams.load(yaml: y))!
		print((node as! [[AnyHashable:Any]])[0]["remote_user"] ?? "" )
	}
	
	public func getVersion() -> String? {
		if let version = version {
			return version
		} else {
			let pomPath = FileManager.default
				.homeDirectoryForCurrentUser
				.appending(path: "dffess")
				.appending(path: product)
				.appending(path: "pom")
				.appendingPathExtension("xml")
			guard let pomContent = try? String(contentsOf: pomPath, encoding: .utf8) else {
				print("Ошибка".red)
				return nil
			}
			var xml = XMLHash.parse(pomContent)
			guard let defaultVersion = try? xml["project"].byKey("version").element?.text else {
				print("Ошибка".red)
				return nil
			}
			return defaultVersion
		}
	}
	
	public func getDevOps() -> DevOps? {
		let jsonPath = FileManager.default
			.homeDirectoryForCurrentUser
			.appending(path: "dffess")
			.appending(path: product)
			.appending(path: "devops")
			.appendingPathExtension("json")
		
		guard let jsonContent = try? String(contentsOf: jsonPath, encoding: .utf8) else {
			print("Ошибка".red)
			return nil
		}
		
		let data = jsonContent.data(using: .utf8)
		guard let data = jsonContent.data(using: .utf8) else { return nil }
		let devops = try? JSONDecoder().decode(DevOps.self, from: data)
		return devops
	}

	public func run() async {
		
//		let url = URL(string: "https://www.w3schools.com/xml/simple.xml")!
//		let result = try! await URLSession.shared.data(from: url)
//		let x = String(decoding: result.0, as: UTF8.self)

		
		guard let version = getVersion() else { return }
		print(version)
		guard let devops = getDevOps() else { return }
		let lePostfix = le == nil ? "" : "_\(le!)"
		let jarName = "\(product)-\(version)-jar-with-dependencies.jar"
		let hdfsPath = "/oozie-app/\(devops.block)/\(devops.datamartGroup)/\(product)\(lePostfix)/\(jarName)"
		let ipaUser = user == nil ? NSUserName() + "_ipa" : user!
		print(ipaUser)
//		print(">>\(xml["project"].children[0]["version"].element?.text ?? "")<<<")
//		xml["root"]["catalog"]


		
		do {
			print("+++")
			let cmd = Console(host: "vm-deb.local", user: NSUserName())
//			let x = try await Run.ssh("echo foo 1>&2")
			var x = try await cmd.ssh("ls -l")
			print(">\(x.0 ?? "") \(x.1)<")
			x = try await cmd.scp(local: <#T##String#>, remote: <#T##String#>)
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

class Console {
	enum RunError: Error {
	  case hostNotSet
	}
	
	var host: String
	var user: String
	var logger: Logger
	
	init(host: String, user: String) {
		self.host = host
		self.user = user
		self.logger = {
			var log = Logger(label: "Run")
			log.logLevel = .warning
			return log
		}()
	}
	
	func scp(local: String, remote: String) async throws -> (String?, Int32) {
		try await shell("scp \(local) \(user)@\(host):\(remote)")
	}
	
	func sftp(_ command: String) async throws -> (String?, Int32)  {
		try await shell("sftp \(user)@\(host) \"\(command)\"")
	}
	
	func ssh(_ command: String) async throws -> (String?, Int32)  {
		try await shell("ssh \(user)@\(host) \"\(command)\"")
	}
	
	func shell(_ command: String) async throws -> (String?, Int32)  {
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
