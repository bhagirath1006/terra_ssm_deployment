const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.static('public'));

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Portfolio Website</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f0f0f0; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; }
        h1 { color: #333; }
        p { color: #666; line-height: 1.6; }
        .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Welcome to My Portfolio</h1>
        <p>This website is deployed automatically using:</p>
        <ul>
          <li>GitHub Actions - CI/CD Pipeline</li>
          <li>Terraform - Infrastructure as Code</li>
          <li>Docker - Container Deployment</li>
          <li>AWS EC2 & ECR - Cloud Infrastructure</li>
        </ul>
        <div class="info">
          <strong>✓ Deployed Successfully!</strong><br>
          Every push to GitHub automatically triggers the pipeline to build, test, and deploy this website.
        </div>
        <p><small>Last deployed: ${new Date().toISOString()}</small></p>
      </div>
    </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`Portfolio website running on port ${port}`);
});
