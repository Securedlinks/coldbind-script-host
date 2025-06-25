// Global variables
let repositories = JSON.parse(localStorage.getItem('vulpine_repositories') || '[]');
let scripts = JSON.parse(localStorage.getItem('vulpine_scripts') || '[]');
let currentEditingScript = null;

// Authentication utilities
const auth = {
    getSessionToken() {
        return localStorage.getItem('vsh_session');
    },
    
    isAuthenticated() {
        const token = this.getSessionToken();
        const expires = localStorage.getItem('vsh_expires');
        return token && expires && Date.now() < parseInt(expires);
    },
    
    logout() {
        const token = this.getSessionToken();
        if (token) {
            fetch('/api/auth/logout', {
                method: 'POST',
                headers: {
                    'X-Session-Token': token
                }
            }).catch(() => {}); // Ignore errors
        }
        
        localStorage.removeItem('vsh_session');
        localStorage.removeItem('vsh_expires');
        window.location.href = '/login.html';
    },
    
    addAuthHeaders(headers = {}) {
        const token = this.getSessionToken();
        if (token) {
            headers['X-Session-Token'] = token;
        }
        return headers;
    }
};

// Check authentication on page load
document.addEventListener('DOMContentLoaded', function() {
    console.log('Page loaded, checking authentication...');
    
    // Temporarily disable authentication check for debugging
    console.log('TEMPORARILY BYPASSING AUTHENTICATION FOR TESTING');
    
    console.log('Initializing app...');
    initializeApp();
    loadRepositories();
    updateRepoSelects();
    
    /* ORIGINAL CODE - TEMPORARILY DISABLED
    // Only redirect if we're definitely not authenticated
    // Don't redirect if we're already on the login page
    if (window.location.pathname !== '/login.html' && !auth.isAuthenticated()) {
        console.log('Not authenticated, redirecting to login...');
        window.location.replace('/login.html'); // Use replace to avoid back button issues
        return;
    }
    
    // Only initialize if we're authenticated or on a test page
    if (auth.isAuthenticated() || window.location.pathname.includes('test') || window.location.pathname.includes('debug')) {
        console.log('Initializing app...');
        initializeApp();
        loadRepositories();
        updateRepoSelects();
    }
    */
});

// Add logout functionality
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        auth.logout();
    }
}

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    loadRepositories();
    updateRepoSelects();
});

// Initialize application
function initializeApp() {
    // Tab switching
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', () => switchTab(btn.dataset.tab));
    });

    // Editor event listeners
    const codeEditor = document.getElementById('codeEditor');
    if (codeEditor) {
        codeEditor.addEventListener('input', updateEditorStats);
    }

    // Create default repository if none exist
    if (repositories.length === 0) {
        createDefaultRepository();
    }
    
    // Add logout button if not exists
    addLogoutButton();
}

function addLogoutButton() {
    const header = document.querySelector('.header');
    if (header && !document.getElementById('logoutBtn')) {
        const logoutBtn = document.createElement('button');
        logoutBtn.id = 'logoutBtn';
        logoutBtn.className = 'logout-btn';
        logoutBtn.innerHTML = '🚪 Logout';
        logoutBtn.onclick = logout;
        header.appendChild(logoutBtn);
    }
}

// Tab switching
function switchTab(tabName) {
    // Update navigation
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

    // Update content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tabName).classList.add('active');

    // Load specific tab content
    if (tabName === 'repositories') {
        loadRepositories();
    } else if (tabName === 'upload') {
        updateRepoSelects();
    } else if (tabName === 'editor') {
        updateRepoSelects();
    }
}

// Create default repository
function createDefaultRepository() {
    const defaultRepo = {
        id: generateId(),
        name: 'vulpine-scripts',
        description: 'Default repository for Vulpine scripts',
        private: false,
        created: new Date().toISOString(),
        files: 0
    };
    repositories.push(defaultRepo);
    saveRepositories();
}

// Repository management
function createRepository() {
    showCreateRepoModal();
}

function showCreateRepoModal() {
    document.getElementById('createRepoModal').style.display = 'block';
}

function createNewRepository() {
    const name = document.getElementById('newRepoName').value.trim();
    const description = document.getElementById('newRepoDescription').value.trim();
    const isPrivate = document.getElementById('newRepoPrivate').checked;

    if (!name) {
        showMessage('Repository name is required', 'error');
        return;
    }

    // Check if repository name already exists
    if (repositories.find(repo => repo.name.toLowerCase() === name.toLowerCase())) {
        showMessage('Repository name already exists', 'error');
        return;
    }

    const newRepo = {
        id: generateId(),
        name: name,
        description: description || 'No description provided',
        private: isPrivate,
        created: new Date().toISOString(),
        files: 0
    };

    repositories.push(newRepo);
    saveRepositories();
    loadRepositories();
    updateRepoSelects();
    closeModal('createRepoModal');
    
    // Clear form
    document.getElementById('newRepoName').value = '';
    document.getElementById('newRepoDescription').value = '';
    document.getElementById('newRepoPrivate').checked = false;

    showMessage('Repository created successfully!', 'success');
}

// Load and display repositories
function loadRepositories() {
    const grid = document.getElementById('repositoriesGrid');
    
    if (repositories.length === 0) {
        grid.innerHTML = '<div class="message">No repositories found. Create your first repository!</div>';
        return;
    }

    grid.innerHTML = repositories.map(repo => {
        const repoScripts = scripts.filter(script => script.repository === repo.id);
        const fileCount = repoScripts.length;
        
        return `
            <div class="repo-card" onclick="viewRepository('${repo.id}')">
                <div class="repo-header">
                    <div class="repo-title">
                        <i class="fas fa-folder${repo.private ? '-lock' : ''}"></i>
                        <span class="repo-name">${escapeHtml(repo.name)}</span>
                    </div>
                    <div class="repo-actions">
                        <button class="btn-icon btn-delete" onclick="event.stopPropagation(); confirmDeleteRepository('${repo.id}', '${escapeHtml(repo.name)}')" title="Delete Repository">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
                <div class="repo-description">${escapeHtml(repo.description)}</div>
                <div class="repo-stats">
                    <div class="repo-files">
                        <i class="fas fa-file-code"></i>
                        <span>${fileCount} file${fileCount !== 1 ? 's' : ''}</span>
                    </div>
                    <div class="repo-date">
                        Created ${formatDate(repo.created)}
                    </div>
                </div>
                <div class="script-files">
                    ${repoScripts.slice(0, 3).map(script => `
                        <div class="script-file" onclick="event.stopPropagation(); viewScript('${script.id}')">
                            <div class="script-file-info">
                                <i class="fas fa-file-code file-icon ${getFileExtension(script.name)}"></i>
                                <span class="script-file-name">${escapeHtml(script.name)}</span>
                            </div>
                            <div class="script-file-actions">
                                <button class="btn btn-copy" onclick="event.stopPropagation(); copyScriptUrl('${script.id}')" title="Copy URL">
                                    <i class="fas fa-copy"></i>
                                </button>
                            </div>
                        </div>
                    `).join('')}
                    ${fileCount > 3 ? `<div class="script-file-info"><span>... and ${fileCount - 3} more files</span></div>` : ''}
                </div>
            </div>
        `;
    }).join('');
}

// View repository details
function viewRepository(repoId) {
    const repo = repositories.find(r => r.id === repoId);
    if (!repo) return;

    const repoScripts = scripts.filter(script => script.repository === repoId);
    
    // For now, just show all scripts in this repo
    // You could create a separate modal for repository details
    console.log('Viewing repository:', repo.name, 'with', repoScripts.length, 'scripts');
}

// Script management
function previewFile() {
    const fileInput = document.getElementById('fileInput');
    const preview = document.getElementById('filePreview');
    const file = fileInput.files[0];

    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.value = e.target.result;
        };
        reader.readAsText(file);

        // Set filename if not already set
        const fileNameInput = document.getElementById('fileName');
        if (!fileNameInput.value) {
            fileNameInput.value = file.name;
        }
    }
}

function uploadScript() {
    const repoId = document.getElementById('repoSelect').value;
    const fileName = document.getElementById('fileName').value.trim();
    const description = document.getElementById('fileDescription').value.trim();
    const content = document.getElementById('filePreview').value;

    if (!repoId) {
        showMessage('Please select a repository', 'error');
        return;
    }

    if (!fileName) {
        showMessage('Please enter a file name', 'error');
        return;
    }

    if (!content) {
        showMessage('Please select a file or enter content', 'error');
        return;
    }

    // Check if file already exists in repository
    const existingScript = scripts.find(script => 
        script.repository === repoId && script.name.toLowerCase() === fileName.toLowerCase()
    );

    if (existingScript) {
        if (!confirm('A file with this name already exists. Do you want to overwrite it?')) {
            return;
        }
        // Remove existing script
        scripts = scripts.filter(script => script.id !== existingScript.id);
    }

    const newScript = {
        id: generateId(),
        repository: repoId,
        name: fileName,
        description: description || 'No description provided',
        content: content,
        created: new Date().toISOString(),
        size: content.length
    };

    scripts.push(newScript);
    saveScripts();
    
    // Update repository file count
    updateRepositoryFileCount(repoId);
    
    // Clear form
    document.getElementById('fileName').value = '';
    document.getElementById('fileDescription').value = '';
    document.getElementById('filePreview').value = '';
    document.getElementById('fileInput').value = '';

    showMessage('Script uploaded successfully!', 'success');
    
    // Refresh repositories view if active
    if (document.getElementById('repositories').classList.contains('active')) {
        loadRepositories();
    }
}

// Script editor
function newScript() {
    document.getElementById('editorFileName').value = '';
    document.getElementById('editorDescription').value = '';
    document.getElementById('codeEditor').value = '';
    document.querySelector('.editor-filename').textContent = 'Untitled Script';
    currentEditingScript = null;
    updateEditorStats();
}

function saveScript() {
    const repoId = document.getElementById('editorRepo').value;
    const fileName = document.getElementById('editorFileName').value.trim();
    const description = document.getElementById('editorDescription').value.trim();
    const content = document.getElementById('codeEditor').value;

    if (!repoId) {
        showMessage('Please select a repository', 'error');
        return;
    }

    if (!fileName) {
        showMessage('Please enter a file name', 'error');
        return;
    }

    if (!content.trim()) {
        showMessage('Please enter some code', 'error');
        return;
    }

    let script;
    if (currentEditingScript) {
        // Update existing script
        script = scripts.find(s => s.id === currentEditingScript);
        if (script) {
            script.name = fileName;
            script.description = description || 'No description provided';
            script.content = content;
            script.size = content.length;
            script.modified = new Date().toISOString();
        }
    } else {
        // Check if file already exists
        const existingScript = scripts.find(script => 
            script.repository === repoId && script.name.toLowerCase() === fileName.toLowerCase()
        );

        if (existingScript) {
            if (!confirm('A file with this name already exists. Do you want to overwrite it?')) {
                return;
            }
            scripts = scripts.filter(script => script.id !== existingScript.id);
        }

        // Create new script
        script = {
            id: generateId(),
            repository: repoId,
            name: fileName,
            description: description || 'No description provided',
            content: content,
            created: new Date().toISOString(),
            size: content.length
        };
        scripts.push(script);
        currentEditingScript = script.id;
    }

    saveScripts();
    updateRepositoryFileCount(repoId);
    document.querySelector('.editor-filename').textContent = fileName;
    
    showMessage('Script saved successfully!', 'success');
    
    // Refresh repositories view if active
    if (document.getElementById('repositories').classList.contains('active')) {
        loadRepositories();
    }
}

function testScript() {
    const content = document.getElementById('codeEditor').value;
    if (!content.trim()) {
        showMessage('No code to test', 'warning');
        return;
    }

    // Generate test loadstring
    const blob = new Blob([content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    
    const loadstringCmd = `loadstring(game:HttpGet("${url}"))()`;
    
    // Copy to clipboard
    if (navigator.clipboard) {
        navigator.clipboard.writeText(loadstringCmd).then(() => {
            showMessage('Test loadstring copied to clipboard! Note: This is a local URL and won\'t work in Roblox.', 'warning');
        });
    } else {
        showMessage('Test mode: Copy the script content manually to test it.', 'warning');
    }
}

function editScript(scriptId = null) {
    if (scriptId) {
        const script = scripts.find(s => s.id === scriptId);
        if (script) {
            document.getElementById('editorRepo').value = script.repository;
            document.getElementById('editorFileName').value = script.name;
            document.getElementById('editorDescription').value = script.description;
            document.getElementById('codeEditor').value = script.content;
            document.querySelector('.editor-filename').textContent = script.name;
            currentEditingScript = script.id;
            updateEditorStats();
        }
    }
    
    switchTab('editor');
    closeModal('scriptModal');
}

// View script details
function viewScript(scriptId) {
    const script = scripts.find(s => s.id === scriptId);
    if (!script) return;

    const repo = repositories.find(r => r.id === script.repository);
    const baseUrl = window.location.origin + window.location.pathname.replace('index.html', '');
    const rawUrl = `${baseUrl}raw/${repo.id}/${script.name}?key=vulpine2025`;
    const loadstringCmd = `loadstring(game:HttpGet("${rawUrl}"))()`;

    document.getElementById('scriptModalTitle').textContent = script.name;
    document.getElementById('modalRepo').textContent = repo ? repo.name : 'Unknown';
    document.getElementById('modalFile').textContent = script.name;
    document.getElementById('modalDate').textContent = formatDate(script.created);
    document.getElementById('modalDescription').textContent = script.description;
    document.getElementById('rawUrl').value = rawUrl;
    document.getElementById('loadstringCmd').value = loadstringCmd;
    document.getElementById('scriptContent').textContent = script.content;

    // Set current script for editing
    currentEditingScript = script.id;

    document.getElementById('scriptModal').style.display = 'block';
}

// Copy script URL
function copyScriptUrl(scriptId) {
    const script = scripts.find(s => s.id === scriptId);
    if (!script) return;

    const repo = repositories.find(r => r.id === script.repository);
    const baseUrl = window.location.origin + window.location.pathname.replace('index.html', '');
    const rawUrl = `${baseUrl}raw/${repo.id}/${script.name}?key=vulpine2025`;

    if (navigator.clipboard) {
        navigator.clipboard.writeText(rawUrl).then(() => {
            showMessage('Script URL copied to clipboard!', 'success');
        });
    } else {
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = rawUrl;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        showMessage('Script URL copied to clipboard!', 'success');
    }
}

// Repository deletion functions
function confirmDeleteRepository(repoId, repoName) {
    if (confirm(`Are you sure you want to delete the repository "${repoName}"?\n\nThis will permanently delete the repository and all its scripts. This action cannot be undone.`)) {
        deleteRepository(repoId);
    }
}

function deleteRepository(repoId) {
    const repo = repositories.find(r => r.id === repoId);
    if (!repo) {
        showMessage('Repository not found!', 'error');
        return;
    }

    // Count scripts that will be deleted
    const repoScripts = scripts.filter(script => script.repository === repoId);
    const scriptCount = repoScripts.length;

    // If using server mode, send delete request to backend
    if (window.location.hostname !== '' && window.location.hostname !== 'localhost') {
        fetch(`/api/repositories/${repoId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                throw new Error(data.error);
            }
            showMessage(`Repository "${repo.name}" and ${data.deletedScripts} script(s) deleted successfully!`, 'success');
            // Refresh data
            loadRepositories();
            updateRepoSelects();
        })
        .catch(error => {
            console.error('Error deleting repository:', error);
            showMessage('Failed to delete repository: ' + error.message, 'error');
        });
    } else {
        // Local storage mode
        // Remove repository from array
        const repoIndex = repositories.findIndex(r => r.id === repoId);
        if (repoIndex !== -1) {
            repositories.splice(repoIndex, 1);
        }

        // Remove all scripts in this repository
        scripts = scripts.filter(script => script.repository !== repoId);

        // Save changes
        saveRepositories();
        saveScripts();

        // Update UI
        loadRepositories();
        updateRepoSelects();

        showMessage(`Repository "${repo.name}" and ${scriptCount} script(s) deleted successfully!`, 'success');
    }
}

// Utility functions
function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString();
}

function getFileExtension(filename) {
    return filename.split('.').pop().toLowerCase();
}

function updateEditorStats() {
    const editor = document.getElementById('codeEditor');
    const content = editor.value;
    const lines = content.split('\n').length;
    const chars = content.length;

    document.getElementById('lineCount').textContent = `Lines: ${lines}`;
    document.getElementById('charCount').textContent = `Chars: ${chars}`;
}

function updateRepoSelects() {
    const selects = ['repoSelect', 'editorRepo'];
    
    selects.forEach(selectId => {
        const select = document.getElementById(selectId);
        if (select) {
            select.innerHTML = '<option value="">Select Repository</option>' +
                repositories.map(repo => 
                    `<option value="${repo.id}">${escapeHtml(repo.name)}</option>`
                ).join('');
        }
    });
}

function updateRepoInfo() {
    const repoId = document.getElementById('repoSelect').value;
    // You can add additional repo info display here if needed
}

function updateRepositoryFileCount(repoId) {
    const repo = repositories.find(r => r.id === repoId);
    if (repo) {
        const fileCount = scripts.filter(script => script.repository === repoId).length;
        repo.files = fileCount;
        saveRepositories();
    }
}

// Search functionality
function searchRepositories() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const repoCards = document.querySelectorAll('.repo-card');
    
    repoCards.forEach(card => {
        const repoName = card.querySelector('.repo-name').textContent.toLowerCase();
        const repoDesc = card.querySelector('.repo-description').textContent.toLowerCase();
        
        if (repoName.includes(searchTerm) || repoDesc.includes(searchTerm)) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// Modal functions
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

function copyToClipboard(inputId) {
    const input = document.getElementById(inputId);
    input.select();
    document.execCommand('copy');
    showMessage('Copied to clipboard!', 'success');
}

// Message system
function showMessage(text, type = 'info') {
    // Remove existing messages
    const existingMessages = document.querySelectorAll('.message');
    existingMessages.forEach(msg => msg.remove());

    const message = document.createElement('div');
    message.className = `message ${type}`;
    message.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
        <span>${escapeHtml(text)}</span>
    `;

    // Insert at the top of the active tab content
    const activeTab = document.querySelector('.tab-content.active');
    activeTab.insertBefore(message, activeTab.firstChild);

    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (message.parentNode) {
            message.remove();
        }
    }, 5000);
}

// Local storage functions
function saveRepositories() {
    localStorage.setItem('vulpine_repositories', JSON.stringify(repositories));
}

function saveScripts() {
    localStorage.setItem('vulpine_scripts', JSON.stringify(scripts));
}

// Close modals when clicking outside
window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
}

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Ctrl+S to save in editor
    if (e.ctrlKey && e.key === 's') {
        e.preventDefault();
        if (document.getElementById('editor').classList.contains('active')) {
            saveScript();
        }
    }
    
    // Escape to close modals
    if (e.key === 'Escape') {
        const openModal = document.querySelector('.modal[style*="block"]');
        if (openModal) {
            openModal.style.display = 'none';
        }
    }
});

// Add sample scripts for demonstration
function addSampleScripts() {
    if (scripts.length === 0 && repositories.length > 0) {
        const defaultRepo = repositories[0];
        
        const sampleScripts = [
            {
                id: generateId(),
                repository: defaultRepo.id,
                name: 'hello.lua',
                description: 'Simple hello world script',
                content: `-- Hello World Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("Hello, " .. LocalPlayer.Name .. "!")
print("Welcome to Vulpine Script Host!")`,
                created: new Date().toISOString(),
                size: 0
            },
            {
                id: generateId(),
                repository: defaultRepo.id,
                name: 'teleport.lua',
                description: 'Simple teleport script',
                content: `-- Simple Teleport Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function teleportTo(position)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        print("Teleported to: " .. tostring(position))
    end
end

-- Usage: teleportTo(Vector3.new(0, 50, 0))
teleportTo(Vector3.new(0, 50, 0))`,
                created: new Date().toISOString(),
                size: 0
            }
        ];
        
        sampleScripts.forEach(script => {
            script.size = script.content.length;
            scripts.push(script);
        });
        
        saveScripts();
        updateRepositoryFileCount(defaultRepo.id);
    }
}

// Initialize sample data on first load
if (localStorage.getItem('vulpine_first_load') !== 'false') {
    setTimeout(() => {
        addSampleScripts();
        loadRepositories();
        localStorage.setItem('vulpine_first_load', 'false');
    }, 1000);
}
