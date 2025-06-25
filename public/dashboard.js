// Dashboard JavaScript for COLDBIND Script Host

let currentRepo = null;
let currentFile = null;

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    loadRepositories();
});

// Authentication
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = '/logout';
    }
}

// Repository Management
async function loadRepositories() {
    try {
        const response = await fetch('/api/repositories');
        const repos = await response.json();
        
        const repoList = document.getElementById('repoList');
        repoList.innerHTML = '';
        
        if (repos.length === 0) {
            repoList.innerHTML = '<p style="color: #999; text-align: center; padding: 20px;">No repositories yet</p>';
            return;
        }
        
        repos.forEach(repo => {
            const repoItem = document.createElement('div');
            repoItem.className = 'repo-item';
            repoItem.textContent = repo;
            repoItem.onclick = () => selectRepository(repo);
            repoList.appendChild(repoItem);
        });
    } catch (error) {
        console.error('Failed to load repositories:', error);
        showError('Failed to load repositories');
    }
}

function selectRepository(repoName) {
    currentRepo = repoName;
    
    // Update active repo in sidebar
    document.querySelectorAll('.repo-item').forEach(item => {
        item.classList.remove('active');
        if (item.textContent === repoName) {
            item.classList.add('active');
        }
    });
    
    // Show repo panel and hide others
    hideAllPanels();
    document.getElementById('repoPanel').classList.remove('hidden');
    document.getElementById('repoTitle').textContent = repoName;
    
    loadRepositoryFiles(repoName);
}

async function loadRepositoryFiles(repoName) {
    try {
        const response = await fetch(`/api/repositories/${repoName}/files`);
        const files = await response.json();
        
        const fileList = document.getElementById('fileList');
        fileList.innerHTML = '';
        
        if (files.length === 0) {
            fileList.innerHTML = '<p style="color: #999; text-align: center; padding: 20px;">No scripts in this repository</p>';
            return;
        }
        
        files.forEach(file => {
            const fileItem = document.createElement('div');
            fileItem.className = 'file-item';
            
            const fileInfo = document.createElement('div');
            fileInfo.className = 'file-info';
            
            const fileName = document.createElement('h4');
            fileName.textContent = file.name;
            
            const fileDetails = document.createElement('p');
            const size = formatFileSize(file.size);
            const date = new Date(file.modified).toLocaleDateString();
            fileDetails.textContent = `${size} • Modified ${date}`;
            
            fileInfo.appendChild(fileName);
            fileInfo.appendChild(fileDetails);
            
            const fileActions = document.createElement('div');
            fileActions.className = 'file-actions';
            
            const editBtn = document.createElement('button');
            editBtn.className = 'btn btn-primary';
            editBtn.textContent = '✏️ Edit';
            editBtn.onclick = () => editFile(repoName, file.name);
            
            const infoBtn = document.createElement('button');
            infoBtn.className = 'btn btn-secondary';
            infoBtn.textContent = 'ℹ️ Info';
            infoBtn.onclick = () => showFileInfo(repoName, file.name);
            
            const deleteBtn = document.createElement('button');
            deleteBtn.className = 'btn btn-danger';
            deleteBtn.textContent = '🗑️';
            deleteBtn.onclick = () => deleteFile(repoName, file.name);
            
            fileActions.appendChild(editBtn);
            fileActions.appendChild(infoBtn);
            fileActions.appendChild(deleteBtn);
            
            fileItem.appendChild(fileInfo);
            fileItem.appendChild(fileActions);
            fileList.appendChild(fileItem);
        });
    } catch (error) {
        console.error('Failed to load files:', error);
        showError('Failed to load repository files');
    }
}

// File Management
async function editFile(repoName, fileName) {
    try {
        const response = await fetch(`/api/repositories/${repoName}/files/${fileName}`);
        const result = await response.json();
        
        if (!result.success) {
            showError(result.message);
            return;
        }
        
        currentFile = { repo: repoName, name: fileName };
        
        hideAllPanels();
        document.getElementById('editorPanel').classList.remove('hidden');
        document.getElementById('editorTitle').textContent = `Editing: ${fileName}`;
        document.getElementById('codeEditor').value = result.content;
    } catch (error) {
        console.error('Failed to load file:', error);
        showError('Failed to load file');
    }
}

async function saveFile() {
    if (!currentFile) return;
    
    const content = document.getElementById('codeEditor').value;
    
    try {
        const response = await fetch(`/api/repositories/${currentFile.repo}/files/${currentFile.name}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ content })
        });
        
        const result = await response.json();
        
        if (result.success) {
            showSuccess('File saved successfully!');
            loadRepositoryFiles(currentFile.repo);
        } else {
            showError(result.message);
        }
    } catch (error) {
        console.error('Failed to save file:', error);
        showError('Failed to save file');
    }
}

async function deleteFile(repoName, fileName) {
    if (!confirm(`Are you sure you want to delete "${fileName}"?`)) return;
    
    try {
        const response = await fetch(`/api/repositories/${repoName}/files/${fileName}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (result.success) {
            showSuccess('File deleted successfully!');
            loadRepositoryFiles(repoName);
            
            // Close editor if this file was being edited
            if (currentFile && currentFile.name === fileName) {
                closeEditor();
            }
        } else {
            showError(result.message);
        }
    } catch (error) {
        console.error('Failed to delete file:', error);
        showError('Failed to delete file');
    }
}

function closeEditor() {
    currentFile = null;
    hideAllPanels();
    
    if (currentRepo) {
        document.getElementById('repoPanel').classList.remove('hidden');
    } else {
        document.getElementById('welcomePanel').classList.remove('hidden');
    }
}

// Repository Creation
function showCreateRepo() {
    document.getElementById('createRepoModal').classList.remove('hidden');
    document.getElementById('repoName').focus();
}

function hideCreateRepo() {
    document.getElementById('createRepoModal').classList.add('hidden');
    document.getElementById('createRepoForm').reset();
}

document.getElementById('createRepoForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const repoName = document.getElementById('repoName').value.trim();
    
    try {
        const response = await fetch('/api/repositories', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name: repoName })
        });
        
        const result = await response.json();
        
        if (result.success) {
            hideCreateRepo();
            showSuccess('Repository created successfully!');
            loadRepositories();
        } else {
            showError(result.message);
        }
    } catch (error) {
        console.error('Failed to create repository:', error);
        showError('Failed to create repository');
    }
});

// Repository Deletion
async function deleteRepository() {
    if (!currentRepo) return;
    
    const confirmText = prompt(`Type "${currentRepo}" to confirm deletion:`);
    if (confirmText !== currentRepo) {
        showError('Repository name does not match');
        return;
    }
    
    try {
        const response = await fetch(`/api/repositories/${currentRepo}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (result.success) {
            showSuccess('Repository deleted successfully!');
            currentRepo = null;
            hideAllPanels();
            document.getElementById('welcomePanel').classList.remove('hidden');
            loadRepositories();
        } else {
            showError(result.message);
        }
    } catch (error) {
        console.error('Failed to delete repository:', error);
        showError('Failed to delete repository');
    }
}

// File Upload
function showUploadDialog() {
    if (!currentRepo) {
        showError('Please select a repository first');
        return;
    }
    document.getElementById('uploadModal').classList.remove('hidden');
}

function hideUploadDialog() {
    document.getElementById('uploadModal').classList.add('hidden');
    document.getElementById('uploadForm').reset();
}

document.getElementById('uploadForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const fileInput = document.getElementById('scriptFile');
    const file = fileInput.files[0];
    
    if (!file) {
        showError('Please select a file');
        return;
    }
    
    const formData = new FormData();
    formData.append('file', file);
    formData.append('repository', currentRepo);
    
    try {
        const response = await fetch('/api/upload', {
            method: 'POST',
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            hideUploadDialog();
            showSuccess('File uploaded successfully!');
            loadRepositoryFiles(currentRepo);
        } else {
            showError(result.message);
        }
    } catch (error) {
        console.error('Failed to upload file:', error);
        showError('Failed to upload file');
    }
});

// File Information
function showFileInfo(repoName = currentFile?.repo, fileName = currentFile?.name) {
    if (!repoName || !fileName) return;
    
    const baseUrl = window.location.origin;
    const loadstringUrl = `${baseUrl}/loadstring/${repoName}/${fileName}`;
    const rawUrl = `${baseUrl}/raw/${repoName}/${fileName}?key=coldbind_access_2024`;
    
    const infoHtml = `
        <div class="file-info-content">
            <div class="info-section">
                <h4>📁 Repository</h4>
                <p>${repoName}</p>
            </div>
            
            <div class="info-section">
                <h4>📄 File Name</h4>
                <p>${fileName}</p>
            </div>
            
            <div class="info-section">
                <h4>🔗 Loadstring URL</h4>
                <p style="word-break: break-all; font-family: monospace; background: rgba(0,0,0,0.3); padding: 8px; border-radius: 4px;">${loadstringUrl}</p>
                <button class="btn btn-secondary" onclick="copyToClipboard('${loadstringUrl}')">📋 Copy Loadstring URL</button>
            </div>
            
            <div class="info-section">
                <h4>🔒 Raw URL (with key)</h4>
                <p style="word-break: break-all; font-family: monospace; background: rgba(0,0,0,0.3); padding: 8px; border-radius: 4px;">${rawUrl}</p>
                <button class="btn btn-secondary" onclick="copyToClipboard('${rawUrl}')">📋 Copy Raw URL</button>
            </div>
            
            <div class="info-section">
                <h4>🎮 Roblox Usage</h4>
                <pre style="background: rgba(0,0,0,0.3); padding: 12px; border-radius: 4px; font-size: 12px; color: #ccc;">loadstring(game:HttpGet("${loadstringUrl}"))()</pre>
                <button class="btn btn-secondary" onclick="copyToClipboard('loadstring(game:HttpGet(&quot;${loadstringUrl}&quot;))()')">📋 Copy Roblox Code</button>
            </div>
        </div>
    `;
    
    document.getElementById('scriptInfo').innerHTML = infoHtml;
    document.getElementById('infoModal').classList.remove('hidden');
}

function hideInfoModal() {
    document.getElementById('infoModal').classList.add('hidden');
}

// Utility Functions
function hideAllPanels() {
    document.getElementById('welcomePanel').classList.add('hidden');
    document.getElementById('repoPanel').classList.add('hidden');
    document.getElementById('editorPanel').classList.add('hidden');
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        showSuccess('Copied to clipboard!');
    }).catch(() => {
        showError('Failed to copy to clipboard');
    });
}

function showSuccess(message) {
    showNotification(message, 'success');
}

function showError(message) {
    showNotification(message, 'error');
}

function showNotification(message, type) {
    // Remove existing notifications
    const existing = document.querySelector('.notification');
    if (existing) {
        existing.remove();
    }
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        border-radius: 8px;
        color: white;
        z-index: 1001;
        animation: slideIn 0.3s ease;
        ${type === 'success' ? 'background: rgba(0, 255, 0, 0.1); border: 1px solid rgba(0, 255, 0, 0.3);' : 'background: rgba(255, 0, 0, 0.1); border: 1px solid rgba(255, 0, 0, 0.3);'}
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 300);
    }, 3000);
}

// Add CSS for animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
    
    .info-section {
        margin-bottom: 20px;
        padding-bottom: 16px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .info-section:last-child {
        border-bottom: none;
    }
    
    .info-section h4 {
        margin-bottom: 8px;
        color: #ffffff;
    }
    
    .info-section p {
        margin-bottom: 8px;
        color: #cccccc;
    }
    
    .info-section pre {
        margin-bottom: 8px;
        white-space: pre-wrap;
        word-wrap: break-word;
    }
`;
document.head.appendChild(style);
