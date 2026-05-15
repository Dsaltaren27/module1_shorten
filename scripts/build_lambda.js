const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const root = path.resolve(__dirname, '..');
const srcLambda = path.join(root, 'src', 'lambda');
const buildLambda = path.join(root, 'build', 'lambda');

function cleanDir(dir) {
  if (fs.existsSync(dir)) {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

function copyFile(src, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

function copyDirectory(src, dest) {
  if (!fs.existsSync(src)) return;
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDirectory(srcPath, destPath);
    } else if (entry.isFile()) {
      copyFile(srcPath, destPath);
    }
  }
}

function main() {
  console.log('Cleaning previous lambda build...');
  cleanDir(buildLambda);

  console.log('Copying Lambda source files...');
  copyDirectory(srcLambda, buildLambda);

  console.log('Writing temporary package.json for Lambda build...');
  const rootPackage = require(path.join(root, 'package.json'));
  const lambdaPackage = {
    name: 'module1-shorten-lambda-build',
    version: '1.0.0',
    description: 'Temporary build package for Lambda deployment',
    main: 'handlers/shorten.js',
    type: 'commonjs',
    dependencies: rootPackage.dependencies || {},
  };
  fs.writeFileSync(path.join(buildLambda, 'package.json'), JSON.stringify(lambdaPackage, null, 2));

  console.log('Installing production dependencies in build folder...');
  execSync('npm install --production', { cwd: buildLambda, stdio: 'inherit' });

  console.log('Lambda build is ready:', buildLambda);
}

main();
