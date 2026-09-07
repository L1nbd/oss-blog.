// Fake SMTP Server for local development
// Receives emails, saves to files, and extracts magic login links

const net = require('net');
const fs = require('fs');
const path = require('path');

const PORT = 2525;
const MAILBOX_DIR = path.join(__dirname, '..', 'runtime', 'mailbox');

// Ensure mailbox directory exists
if (!fs.existsSync(MAILBOX_DIR)) {
    fs.mkdirSync(MAILBOX_DIR, { recursive: true });
}

function extractLoginLink(emailData) {
    // Try to find login link in plain text or HTML
    const patterns = [
        /(http:\/\/localhost:2368\/members\/\?token=[^\s<>"']+)/g,
        /(http:\/\/127\.0\.0\.1:2368\/members\/\?token=[^\s<>"']+)/g
    ];
    
    for (const pattern of patterns) {
        const matches = emailData.match(pattern);
        if (matches && matches.length > 0) {
            return matches[matches.length - 1]; // Return the latest link
        }
    }
    return null;
}

function decodeBase64(content) {
    try {
        return Buffer.from(content, 'base64').toString('utf-8');
    } catch (e) {
        return content;
    }
}

function extractPlainText(emailData) {
    // Try to find plain text part in multipart email
    const plainTextMatch = emailData.match(/Content-Type: text\/plain;[\s\S]*?Content-Transfer-Encoding: base64\s*\n([\s\S]*?)\n---/);
    if (plainTextMatch) {
        return decodeBase64(plainTextMatch[1].replace(/\s/g, ''));
    }
    return emailData;
}

const server = net.createServer((socket) => {
    console.log('[SMTP] Client connected:', socket.remoteAddress);
    
    socket.write('220 Fake SMTP Server Ready\r\n');
    
    let dataMode = false;
    let emailData = '';
    let fromAddr = '';
    let toAddr = '';
    let subject = '';
    
    socket.on('data', (data) => {
        const message = data.toString();
        
        if (dataMode) {
            emailData += message;
            if (message.trim() === '.') {
                dataMode = false;
                console.log('[SMTP] Email received completely');
                
                // Extract subject
                const subjectMatch = emailData.match(/Subject: ([^\n]+)/);
                if (subjectMatch) {
                    subject = subjectMatch[1].trim();
                }
                
                // Extract plain text for login link
                const plainText = extractPlainText(emailData);
                const loginLink = extractLoginLink(plainText) || extractLoginLink(emailData);
                
                // Save email to file
                const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
                const emailFile = path.join(MAILBOX_DIR, `email-${timestamp}.eml`);
                fs.writeFileSync(emailFile, emailData, 'utf-8');
                console.log('[SMTP] Email saved to:', emailFile);
                
                // Save latest login link
                if (loginLink) {
                    const linkFile = path.join(MAILBOX_DIR, 'latest-login-link.txt');
                    fs.writeFileSync(linkFile, loginLink, 'utf-8');
                    console.log('');
                    console.log('========================================');
                    console.log('  LOGIN LINK FOUND!');
                    console.log('========================================');
                    console.log('  To:', toAddr);
                    console.log('  Subject:', subject);
                    console.log('  Link:', loginLink);
                    console.log('========================================');
                    console.log('');
                }
                
                socket.write('250 Message accepted\r\n');
            }
            return;
        }
        
        if (message.startsWith('EHLO') || message.startsWith('HELO')) {
            socket.write('250-Fake SMTP Server\r\n');
            socket.write('250 AUTH PLAIN LOGIN\r\n');
        } else if (message.startsWith('MAIL FROM')) {
            const fromMatch = message.match(/<([^>]+)>/);
            if (fromMatch) fromAddr = fromMatch[1];
            socket.write('250 OK\r\n');
        } else if (message.startsWith('RCPT TO')) {
            const toMatch = message.match(/<([^>]+)>/);
            if (toMatch) toAddr = toMatch[1];
            console.log('[SMTP] Mail from:', fromAddr, '->', toAddr);
            socket.write('250 OK\r\n');
        } else if (message.startsWith('DATA')) {
            dataMode = true;
            emailData = '';
            socket.write('354 End data with <CR><LF>.<CR><LF>\r\n');
        } else if (message.startsWith('AUTH')) {
            socket.write('235 Authentication successful\r\n');
        } else if (message.startsWith('QUIT')) {
            socket.write('221 Bye\r\n');
            socket.end();
        } else if (message.startsWith('RSET')) {
            socket.write('250 OK\r\n');
        } else if (message.startsWith('NOOP')) {
            socket.write('250 OK\r\n');
        } else {
            socket.write('250 OK\r\n');
        }
    });
    
    socket.on('end', () => {
        console.log('[SMTP] Client disconnected');
    });
    
    socket.on('error', (err) => {
        console.error('[SMTP] Error:', err.message);
    });
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`[SMTP] Fake SMTP Server started, listening on 127.0.0.1:${PORT}`);
    console.log(`[SMTP] Mailbox directory: ${MAILBOX_DIR}`);
    console.log(`[SMTP] Login links will be saved to: ${path.join(MAILBOX_DIR, 'latest-login-link.txt')}`);
});

server.on('error', (err) => {
    console.error('[SMTP] Server error:', err.message);
});
