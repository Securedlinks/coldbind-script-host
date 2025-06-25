const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const session = require('express-session');

const app = express();
const PORT = process.env.PORT || 3000;

// Session configuration
app.use(session({
    secret: 'coldbind-secret-key-change-in-production',
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false }
}));

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
app.use(express.static('.'));

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const repoName = req.body.repository || 'default';
        const uploadPath = path.join(__dirname, 'repositories', repoName);
        
        // Create directory if it doesn't exist
        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath, { recursive: true });
        }
        
        cb(null, uploadPath);
    },
    filename: function (req, file, cb) {
        cb(null, file.originalname);
    }
});

const upload = multer({ 
    storage: storage,
    fileFilter: (req, file, cb) => {
        // Allow only certain file types
        const allowedTypes = ['.lua', '.txt', '.md'];
        const ext = path.extname(file.originalname).toLowerCase();
        if (allowedTypes.includes(ext)) {
            cb(null, true);
        } else {
            cb(new Error('Only .lua, .txt, and .md files are allowed'), false);
        }
    }
});

// Authentication middleware
const requireAuth = (req, res, next) => {
    if (req.session.authenticated) {
        next();
    } else {
        res.status(401).json({ error: 'Authentication required' });
    }
};

// Routes

// Serve login page
app.get('/', (req, res) => {
    if (req.session.authenticated) {
        res.sendFile(path.join(__dirname, 'index.html'));
    } else {
        res.sendFile(path.join(__dirname, 'public', 'login.html'));
    }
});

// Serve dashboard
app.get('/dashboard', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});

// Login endpoint
app.post('/login', (req, res) => {
    const { password } = req.body;
    
    // Simple password check
    const validPassword = 'admin123';
    
    if (password === validPassword) {
        req.session.authenticated = true;
        res.json({ success: true });
    } else {
        res.status(401).json({ error: 'Invalid password' });
    }
});

// Logout endpoint
app.post('/logout', (req, res) => {
    req.session.destroy();
    res.json({ success: true });
});

// Get repositories
app.get('/api/repositories', requireAuth, (req, res) => {
    try {
        const repoPath = path.join(__dirname, 'repositories');
        if (!fs.existsSync(repoPath)) {
            fs.mkdirSync(repoPath, { recursive: true });
        }
        
        const repos = fs.readdirSync(repoPath, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => {
                const repoDir = path.join(repoPath, dirent.name);
                const files = fs.readdirSync(repoDir).filter(file => 
                    file.endsWith('.lua') || file.endsWith('.txt') || file.endsWith('.md')
                );
                
                return {
                    name: dirent.name,
                    files: files,
                    fileCount: files.length,
                    lastModified: fs.statSync(repoDir).mtime
                };
            });
        
        res.json(repos);
    } catch (error) {
        console.error('Error getting repositories:', error);
        res.status(500).json({ error: 'Failed to get repositories' });
    }
});

// Create repository
app.post('/api/repositories', requireAuth, (req, res) => {
    try {
        const { name } = req.body;
        
        if (!name || !/^[a-zA-Z0-9_-]+$/.test(name)) {
            return res.status(400).json({ error: 'Invalid repository name' });
        }
        
        const repoPath = path.join(__dirname, 'repositories', name);
        
        if (fs.existsSync(repoPath)) {
            return res.status(400).json({ error: 'Repository already exists' });
        }
        
        fs.mkdirSync(repoPath, { recursive: true });
        
        res.json({ success: true, name });
    } catch (error) {
        console.error('Error creating repository:', error);
        res.status(500).json({ error: 'Failed to create repository' });
    }
});

// Delete repository
app.delete('/api/repositories/:name', requireAuth, (req, res) => {
    try {
        const { name } = req.params;
        const repoPath = path.join(__dirname, 'repositories', name);
        
        if (!fs.existsSync(repoPath)) {
            return res.status(404).json({ error: 'Repository not found' });
        }
        
        // Remove directory and all contents
        fs.rmSync(repoPath, { recursive: true, force: true });
        
        res.json({ success: true });
    } catch (error) {
        console.error('Error deleting repository:', error);
        res.status(500).json({ error: 'Failed to delete repository' });
    }
});

// Get files in repository
app.get('/api/repositories/:name/files', requireAuth, (req, res) => {
    try {
        const { name } = req.params;
        const repoPath = path.join(__dirname, 'repositories', name);
        
        if (!fs.existsSync(repoPath)) {
            return res.status(404).json({ error: 'Repository not found' });
        }
        
        const files = fs.readdirSync(repoPath)
            .filter(file => file.endsWith('.lua') || file.endsWith('.txt') || file.endsWith('.md'))
            .map(file => {
                const filePath = path.join(repoPath, file);
                const stats = fs.statSync(filePath);
                return {
                    name: file,
                    size: stats.size,
                    lastModified: stats.mtime,
                    loadstringUrl: `${req.protocol}://${req.get('host')}/loadstring/${name}/${file}`
                };
            });
        
        res.json(files);
    } catch (error) {
        console.error('Error getting files:', error);
        res.status(500).json({ error: 'Failed to get files' });
    }
});

// Get file content
app.get('/api/repositories/:repo/files/:file', requireAuth, (req, res) => {
    try {
        const { repo, file } = req.params;
        const filePath = path.join(__dirname, 'repositories', repo, file);
        
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: 'File not found' });
        }
        
        const content = fs.readFileSync(filePath, 'utf8');
        const stats = fs.statSync(filePath);
        
        res.json({
            name: file,
            content: content,
            size: stats.size,
            lastModified: stats.mtime,
            loadstringUrl: `${req.protocol}://${req.get('host')}/loadstring/${repo}/${file}`
        });
    } catch (error) {
        console.error('Error getting file:', error);
        res.status(500).json({ error: 'Failed to get file' });
    }
});

// Save file content
app.put('/api/repositories/:repo/files/:file', requireAuth, (req, res) => {
    try {
        const { repo, file } = req.params;
        const { content } = req.body;
        const filePath = path.join(__dirname, 'repositories', repo, file);
        
        // Ensure directory exists
        const repoPath = path.join(__dirname, 'repositories', repo);
        if (!fs.existsSync(repoPath)) {
            fs.mkdirSync(repoPath, { recursive: true });
        }
        
        fs.writeFileSync(filePath, content, 'utf8');
        
        res.json({ success: true });
    } catch (error) {
        console.error('Error saving file:', error);
        res.status(500).json({ error: 'Failed to save file' });
    }
});

// Delete file
app.delete('/api/repositories/:repo/files/:file', requireAuth, (req, res) => {
    try {
        const { repo, file } = req.params;
        const filePath = path.join(__dirname, 'repositories', repo, file);
        
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({ error: 'File not found' });
        }
        
        fs.unlinkSync(filePath);
        
        res.json({ success: true });
    } catch (error) {
        console.error('Error deleting file:', error);
        res.status(500).json({ error: 'Failed to delete file' });
    }
});

// Upload file
app.post('/api/upload', requireAuth, upload.single('file'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }
        
        const { repository } = req.body;
        
        res.json({
            success: true,
            filename: req.file.filename,
            repository: repository,
            size: req.file.size,
            loadstringUrl: `${req.protocol}://${req.get('host')}/loadstring/${repository}/${req.file.filename}`
        });
    } catch (error) {
        console.error('Error uploading file:', error);
        res.status(500).json({ error: 'Failed to upload file' });
    }
});

// Loadstring endpoint - serves raw file content
app.get('/loadstring/:repo/:file', (req, res) => {
    try {
        const { repo, file } = req.params;
        const filePath = path.join(__dirname, 'repositories', repo, file);
        
        if (!fs.existsSync(filePath)) {
            return res.status(404).send('-- File not found');
        }
        
        const content = fs.readFileSync(filePath, 'utf8');
        res.setHeader('Content-Type', 'text/plain');
        res.send(content);
    } catch (error) {
        console.error('Error serving loadstring:', error);
        res.status(500).send('-- Error loading script');
    }
});

// Special loadstring for default files
app.get('/loadstring/default/:file', (req, res) => {
    try {
        const { file } = req.params;
        const filePath = path.join(__dirname, 'loadstring', 'default', file);
        
        if (!fs.existsSync(filePath)) {
            return res.status(404).send('-- File not found');
        }
        
        const content = fs.readFileSync(filePath, 'utf8');
        res.setHeader('Content-Type', 'text/plain');
        res.send(content);
    } catch (error) {
        console.error('Error serving default loadstring:', error);
        res.status(500).send('-- Error loading script');
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`COLDBIND Script Host running on port ${PORT}`);
    console.log(`Main app: http://localhost:${PORT}`);
    console.log(`Dashboard: http://localhost:${PORT}/dashboard`);
});

module.exports = app;
