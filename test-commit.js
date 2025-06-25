// Test script to trigger auto-commit
const fs = require('fs');
const fetch = require('node-fetch');

async function testAutoCommit() {
    try {
        // Login first
        const loginResponse = await fetch('http://localhost:3000/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ password: 'admin123' })
        });
        
        const loginData = await loginResponse.json();
        console.log('Login response:', loginData);
        
        if (!loginData.success) {
            console.error('Login failed');
            return;
        }
        
        // Read the current Hub.lua file
        const filePath = './repositories/COLDBINDHub/Hub.lua';
        const currentContent = fs.readFileSync(filePath, 'utf8');
        
        // Add a test comment with timestamp
        const timestamp = new Date().toISOString();
        const updatedContent = currentContent.replace(
            '-- Auto-commit test: Updated on June 25, 2025',
            `-- Auto-commit test: Updated on ${timestamp}`
        );
        
        // Update the file through API to trigger auto-commit
        const updateResponse = await fetch('http://localhost:3000/api/repositories/COLDBINDHub/files/Hub.lua', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Cookie': loginResponse.headers.get('set-cookie')
            },
            body: JSON.stringify({ content: updatedContent })
        });
        
        const updateData = await updateResponse.json();
        console.log('Update response:', updateData);
        
    } catch (error) {
        console.error('Error:', error);
    }
}

testAutoCommit();
