Sinatra backend for html5 uploads
=========

This is a simple backend for html5 uploads, made with Sinatra and jQuery File Upload Plugin, focused primarily on providing a backend for very large uploads with support for resuming interrupted uploads.

Features
---
- Resumable uploads
- In theory, unlimited file sizes (tested up to 10Gb)
- Multiple files at once

Requirements
----------
  - Unix or compatible OS
  - Ruby 1.9.3 or greater
  - Bundler

How to install?
---------------
Download the files, and for the development version, cd into the directory and run

    bundle install
    
After the installation finishes, you can run the server with

    rackup
    
and you should be able to reach the app at http://localhost:9292. 

How to use?
---
There are two major components to this setup: the frontend, which is built with blueimp's [jQuery multiple file uploader](https://github.com/blueimp/jQuery-File-Upload) and the [Sinatra](http://www.sinatrarb.com/) backend.

In the backend, the app provides three routes, found in app/upload.rb (the main app file):

 - "/" aka the index, which displays the upload UI
 - POST "/upload" which accepts uploaded chunks
 - GET "/upload" which accepts JSON in the format
    
        {file: <filename>}

    and returns 

        {status: 200, file: {name: <filename>, size: <uploaded bytes so far>}}
          
          
  javascript uploader can then use this info to figure out where to resume the upload.
    
You can customize the upload directory, or submit other data during the file upload, directly in the upload.rb.

As far as the frontend script goes, you can pretty much use anything that's based on jQuery multiple file uploader, for example Adam Filkor's [beautiful html5uploader](http://html5uploader.filkor.org/)

Licence
---
MIT
