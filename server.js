const express = require('express');
const session = require('express-session');
const multer = require('multer');
const bcrypt = require('bcryptjs');
const fs = require('fs-extra');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuration
const ADMIN_PASSWORD_HASH = '$2a$10$QhSZOno9NXw2JX9rKM.wTuSF6eetzyB9vx43htcl7pyRwuSTNfgsO'; // "admin123"
const ACCESS_KEY = 'coldbind_access_2024';

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
app.use(session({
    secret: 'coldbind-script-host-secret-2024',
    resave: false,
    saveUninitialized: false,
    cookie: { 
        secure: false,
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
    }
}));

// File upload configuration
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const repo = req.body.repository || 'default';
        const dir = path.join('repositories', repo);
        fs.ensureDirSync(dir);
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname);
    }
});
const upload = multer({ storage });

// Ensure directories exist
fs.ensureDirSync('repositories');
fs.ensureDirSync('loadstring');
fs.ensureDirSync('loadstring/default');
fs.ensureDirSync('public');

// Authentication middleware
function requireAuth(req, res, next) {
    if (req.session && req.session.authenticated) {
        return next();
    }
    return res.redirect('/login');
}

// Routes
app.get('/', (req, res) => {
    if (req.session && req.session.authenticated) {
        res.redirect('/dashboard');
    } else {
        res.redirect('/login');
    }
});

app.get('/login', (req, res) => {
    if (req.session && req.session.authenticated) {
        return res.redirect('/dashboard');
    }
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

app.post('/login', async (req, res) => {
    const { password } = req.body;
    
    if (!password) {
        return res.status(400).json({ success: false, message: 'Password required' });
    }
    
    try {
        const isValid = await bcrypt.compare(password, ADMIN_PASSWORD_HASH);
        if (isValid) {
            req.session.authenticated = true;
            res.json({ success: true });
        } else {
            res.status(401).json({ success: false, message: 'Invalid password' });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: 'Authentication error' });
    }
});

app.get('/dashboard', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});

app.get('/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            console.error('Session destruction error:', err);
        }
        res.redirect('/login');
    });
});

// API Routes
app.get('/api/repositories', requireAuth, (req, res) => {
    try {
        const repos = fs.readdirSync('repositories', { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name);
        res.json(repos);
    } catch (error) {
        res.json([]);
    }
});

app.post('/api/repositories', requireAuth, (req, res) => {
    const { name } = req.body;
    if (!name || !/^[a-zA-Z0-9_-]+$/.test(name)) {
        return res.status(400).json({ success: false, message: 'Invalid repository name' });
    }
    
    const repoPath = path.join('repositories', name);
    if (fs.existsSync(repoPath)) {
        return res.status(409).json({ success: false, message: 'Repository already exists' });
    }
    
    try {
        fs.ensureDirSync(repoPath);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Failed to create repository' });
    }
});

app.delete('/api/repositories/:name', requireAuth, (req, res) => {
    const { name } = req.params;
    const repoPath = path.join('repositories', name);
    
    try {
        if (fs.existsSync(repoPath)) {
            fs.removeSync(repoPath);
            res.json({ success: true });
        } else {
            res.status(404).json({ success: false, message: 'Repository not found' });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: 'Failed to delete repository' });
    }
});

app.get('/api/repositories/:repo/files', requireAuth, (req, res) => {
    const { repo } = req.params;
    const repoPath = path.join('repositories', repo);
    
    if (!fs.existsSync(repoPath)) {
        return res.status(404).json({ success: false, message: 'Repository not found' });
    }
    
    try {
        const files = fs.readdirSync(repoPath)
            .filter(file => fs.statSync(path.join(repoPath, file)).isFile())
            .map(file => ({
                name: file,
                size: fs.statSync(path.join(repoPath, file)).size,
                modified: fs.statSync(path.join(repoPath, file)).mtime
            }));
        res.json(files);
    } catch (error) {
        res.status(500).json({ success: false, message: 'Failed to read repository' });
    }
});

app.post('/api/upload', requireAuth, upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ success: false, message: 'No file uploaded' });
    }
    res.json({ success: true, filename: req.file.filename });
});

app.get('/api/repositories/:repo/files/:filename', requireAuth, (req, res) => {
    const { repo, filename } = req.params;
    const filePath = path.join('repositories', repo, filename);
    
    if (!fs.existsSync(filePath)) {
        return res.status(404).json({ success: false, message: 'File not found' });
    }
    
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        res.json({ success: true, content });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Failed to read file' });
    }
});

app.put('/api/repositories/:repo/files/:filename', requireAuth, (req, res) => {
    const { repo, filename } = req.params;
    const { content } = req.body;
    const filePath = path.join('repositories', repo, filename);
    
    try {
        fs.writeFileSync(filePath, content);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Failed to save file' });
    }
});

app.delete('/api/repositories/:repo/files/:filename', requireAuth, (req, res) => {
    const { repo, filename } = req.params;
    const filePath = path.join('repositories', repo, filename);
    
    if (!fs.existsSync(filePath)) {
        return res.status(404).json({ success: false, message: 'File not found' });
    }
    
    try {
        fs.unlinkSync(filePath);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Failed to delete file' });
    }
});

// Raw script access for Roblox loadstring
app.get('/raw/:repo/:filename', (req, res) => {
    const { key } = req.query;
    const { repo, filename } = req.params;
    
    console.log(`[RAW] Request from ${req.ip} for ${repo}/${filename}`);
    console.log(`[RAW] User-Agent: ${req.get('User-Agent') || 'None'}`);
    console.log(`[RAW] Key provided: ${key ? 'Yes' : 'No'}`);
    
    if (key !== ACCESS_KEY) {
        console.log(`[RAW] Access denied - invalid key`);
        return res.status(403).send('-- Access denied');
    }
    
    const filePath = path.join('repositories', repo, filename);
    console.log(`[RAW] Looking for file: ${filePath}`);
    
    if (!fs.existsSync(filePath)) {
        console.log(`[RAW] File not found: ${filePath}`);
        return res.status(404).send('-- Script not found');
    }
    
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        console.log(`[RAW] Successfully serving script (${content.length} characters)`);
        res.setHeader('Content-Type', 'text/plain');
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.send(content);
    } catch (error) {
        console.error(`[RAW] Error reading script:`, error);
        res.status(500).send('-- Error loading script');
    }
});

// API Raw script access (alternative endpoint)
app.get('/api/raw/:repo/:filename', (req, res) => {
    const { key } = req.query;
    const { repo, filename } = req.params;
    
    if (key !== ACCESS_KEY) {
        return res.status(403).send('-- Access denied');
    }
    
    const filePath = path.join('repositories', repo, filename);
    
    if (!fs.existsSync(filePath)) {
        return res.status(404).send('-- Script not found');
    }
    
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        res.setHeader('Content-Type', 'text/plain');
        res.send(content);
    } catch (error) {
        res.status(500).send('-- Error loading script');
    }
});

app.listen(PORT, () => {
    console.log(`COLDBIND Script Host running on http://localhost:${PORT}`);
    console.log(`Access key: ${ACCESS_KEY}`);
    console.log(`Admin password: admin123`);
});
