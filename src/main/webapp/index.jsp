<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>End-to-End CI/CD Pipeline — Jenkins • Maven • SonarQube • Nexus • Ansible</title>
  <style>
    body{font-family:Inter, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial;line-height:1.6;color:#111;background:#f7f9fb;padding:32px}
    .container{max-width:900px;margin:0 auto;background:#fff;padding:28px;border-radius:12px;box-shadow:0 8px 30px rgba(17,24,39,0.08)}
    h1{font-size:28px;margin-bottom:6px;color:#0f172a}
    p.lead{color:#334155}
    .pill{display:inline-block;background:#eef2ff;color:#3730a3;padding:6px 10px;border-radius:999px;font-weight:600;font-size:13px}
    h2{border-left:4px solid #e2e8f0;padding-left:12px;color:#0f172a}
    ul{margin-left:20px}
    pre{background:#0b1220;color:#d1fae5;padding:14px;border-radius:8px;overflow:auto}
    code{background:#eef2ff;padding:2px 6px;border-radius:6px}
    .grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
    .card{background:#f8fafc;padding:12px;border-radius:10px;border:1px solid #e6edf3}
    footer{font-size:13px;color:#64748b;margin-top:18px}
    .btn{display:inline-block;background:#0ea5a4;color:white;padding:8px 12px;border-radius:8px;text-decoration:none}
  </style>
</head>
<body>
  <div class="container">
    <h1>End-to-End CI/CD Pipeline with Jenkins, Maven, SonarQube, Nexus &amp; Ansible</h1>
    <p class="lead">A concise project overview describing an automated pipeline that builds, analyzes, stores and deploys a Java web app (WAR) using industry-standard DevOps tools.</p>
    <p><span class="pill">Stack</span> Jenkins • Maven • SonarQube • Nexus Repository Manager • Ansible • Tomcat</p>

    <h2>Project Summary</h2>
    <p>This project implements a full CI/CD workflow for a Java web application. From source code checkout to production-like deployment, the pipeline executes the following high-level steps:</p>
    <ul>
      <li>Checkout source from Git</li>
      <li>Build with Maven and produce a WAR artifact</li>
      <li>Run static code analysis with SonarQube</li>
      <li>Upload the artifact to Nexus (release repository)</li>
      <li>Use Ansible to deploy the artifact to Tomcat on target servers</li>
    </ul>

    <h2>Architecture (logical)</h2>
    <div class="grid">
      <div class="card">
        <strong>Jenkins</strong>
        <p>Orchestrates the pipeline using a declarative <code>Jenkinsfile</code>. Runs Maven jobs, calls Sonar and pushes artifacts to Nexus. Uses Ansible plugin to trigger deployments.</p>
      </div>
      <div class="card">
        <strong>SonarQube</strong>
        <p>Performs static code quality checks (rules, duplications, test coverage). Pipeline passes tokens to Sonar server for authentication.</p>
      </div>

      <div class="card">
        <strong>Nexus Repository</strong>
        <p>Stores build artifacts (WARs). Pipeline uploads artifacts with credentials managed inside Jenkins.</p>
      </div>
      <div class="card">
        <strong>Ansible &amp; Tomcat</strong>
        <p>Ansible playbooks install Java/Tomcat, deploy the WAR to <code>/usr/local/tomcat9/webapps</code>, and control systemd to start/stop Tomcat.</p>
      </div>
    </div>

    <h2>Jenkinsfile (core flow)</h2>
    <pre><code>pipeline {
  agent any
  tools { maven "3.9.9" }
  environment { SONAR_URL = "http://192.168.10.162:9000" }
  stages {
    stage('Checkout'){ steps { git credentialsId: 'java', url: 'https://github.com/Hima0206/myweb.git' } }
    stage('Build'){ steps { sh 'mvn clean package -DskipTests' } }
    stage('Quality'){ steps { withCredentials([string(credentialsId:'sonar-token', variable:'SONAR_AUTH_TOKEN')]) { sh 'mvn sonar:sonar -Dsonar.host.url=$SONAR_URL -Dsonar.token=$SONAR_AUTH_TOKEN' } } }
    stage('Push') { steps { /* nexusArtifactUploader config */ } }
    stage('Deploy'){ steps { ansiblePlaybook credentialsId:'ansible-key', inventory:'dev.in', playbook:'copy.yml' } }
  }
}
</code></pre>

    <h2>Ansible (what it does)</h2>
    <ul>
      <li>Installs Java (Corretto or OpenJDK depending on OS)</li>
      <li>Downloads and extracts Tomcat into <code>/usr/local</code></li>
      <li>Creates a <code>tomcat</code> system user and systemd service</li>
      <li>Deploys the WAR into <code>/usr/local/tomcat9/webapps</code> and restarts Tomcat</li>
    </ul>

    <h2>How to run (high-level)</h2>
    <ol>
      <li>Configure Jenkins global tools: Maven &amp; Ansible plugin, add credentials (git, nexus, sonar, ansible-key).</li>
      <li>Import project into Jenkins and point to the repository containing the Jenkinsfile.</li>
      <li>Ensure SonarQube and Nexus are reachable from the Jenkins controller.</li>
      <li>Provide a working Ansible inventory (e.g., <code>dev.in</code>) and playbook (<code>copy.yml</code>).</li>
    </ol>

    <h2>Files included</h2>
    <ul>
      <li><code>Jenkinsfile</code> — pipeline definition</li>
      <li><code>playbooks/tomcat.yaml</code> — installs Tomcat &amp; manages service</li>
      <li><code>playbooks/deploy.yml</code> — copies WAR to target and restarts Tomcat</li>
      <li><code>inventory/dev.in</code> — Ansible inventory for dev servers</li>
      <li><code>pom.xml</code> — Maven project descriptor</li>
    </ul>

    <h2>Security &amp; Best Practices</h2>
    <ul>
      <li>Store credentials in Jenkins Credentials store; never in plain text.</li>
      <li>Use host key checking or manage known_hosts for SSH (avoid disabling unless temporary).</li>
      <li>Run Sonar quality gates and fail the pipeline on critical issues.</li>
      <li>Use versioned artifact repositories and immutable deployments.</li>
    </ul>

    <footer>
      <p>Created: <strong>Project: CI/CD for Java Web App</strong> — Includes Jenkins, Maven, SonarQube, Nexus and Ansible automation.</p>
      <p><a class="btn" href="#">Download HTML</a></p>
    </footer>
  </div>
</body>
</html>
