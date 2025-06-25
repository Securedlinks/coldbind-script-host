// Test script to trigger full GitHub sync
const fetch = require('node-fetch');

async function testFullSync() {
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
        
        console.log('Starting full GitHub sync...');
        
        // Trigger full sync
        const syncResponse = await fetch('http://localhost:3000/api/sync-to-github', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Cookie': loginResponse.headers.get('set-cookie')
            }
        });
        
        const syncData = await syncResponse.json();
        console.log('Sync response:', syncData);
        
        if (syncData.success) {
            console.log(`\nSync Results:`);
            syncData.results.forEach(result => {
                console.log(`${result.file}: ${result.status}`);
                if (result.error) {
                    console.log(`  Error: ${result.error}`);
                }
            });
        }
        
    } catch (error) {
        console.error('Error:', error);
    }
}

testFullSync();
