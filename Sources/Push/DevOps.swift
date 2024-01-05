//
//  File.swift
//  
//
//  Created by Симонов Иван Дмитриевич on 31.12.2023.
//

import Foundation

public struct DevOps: Codable {
	let standName, build: String
	let nexus3: Nexus3
	let block, datamartGroup, datamartName, datamartAnsibleVars: String
	let sqPRKey, saPRName, sqScanFolder, sqBinaryFolder: String
	let sqOptions, sastConf, emails: String
	let runHiveScriptSQL: Bool
	let jiraTaskRelease: String
	let maven: Maven
	let ess: Ess
	let distribFiles: [DistribFile]
	let templateFiles, workflowToRun: [String]

	enum CodingKeys: String, CodingKey {
		case standName = "stand_name"
		case build, nexus3, block
		case datamartGroup = "datamart_group"
		case datamartName = "datamart_name"
		case datamartAnsibleVars = "datamart_ansible_vars"
		case sqPRKey = "sq_pr_key"
		case saPRName = "sa_pr_name"
		case sqScanFolder = "sq_scan_folder"
		case sqBinaryFolder = "sq_binary_folder"
		case sqOptions = "sq_options"
		case sastConf = "sast_conf"
		case emails
		case runHiveScriptSQL = "run_hive_ script_sql"
		case jiraTaskRelease = "jira_task_release"
		case maven, ess
		case distribFiles = "distrib_files"
		case templateFiles = "template_files"
		case workflowToRun = "workflow_to_run"
	}
}

// MARK: - DistribFile
struct DistribFile: Codable {
	let source, destination: String
}

// MARK: - Ess
struct Ess: Codable {
	let meta: [String]
}

// MARK: - Maven
struct Maven: Codable {
	let jdk: Int
	let pomPath, setPath: String

	enum CodingKeys: String, CodingKey {
		case jdk
		case pomPath = "pom_path"
		case setPath = "set_path"
	}
}

// MARK: - Nexus3
struct Nexus3: Codable {
	let ciItService, ciAsFP: String

	enum CodingKeys: String, CodingKey {
		case ciItService = "ci_it_service"
		case ciAsFP = "ci_as_fp"
	}
}
