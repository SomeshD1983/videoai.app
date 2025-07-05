<Video className="h-8 w-8 text-white opacity-0 group-hover:opacity-100 transition-opacity" />
                  </div>
                  {project.status === 'processing' && project.progress && (
                    <div className="absolute bottom-2 left-2 right-2 bg-white bg-opacity-90 rounded px-2 py-1">
                      <div className="flex items-center justify-between text-xs">
                        <span>Processing</span>
                        <span>{project.progress}%</span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-1 mt-1">
                        <div 
                          className="bg-blue-600 h-1 rounded-full transition-all duration-300"
                          style={{ width: `${project.progress}%` }}
                        ></div>
                      </div>
                    </div>
                  )}
                </div>
                <div className="p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-medium text-gray-900 truncate">
                      {project.title}
                    </h3>
                    <span className={`px-2 py-1 text-xs font-medium rounded-full flex items-center space-x-1 ${getStatusColor(project.status)}`}>
                      {getStatusIcon(project.status)}
                      <span className="capitalize">{project.status}</span>
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">
                    Created {formatDate(project.createdAt)}
                  </p>
                  {project.videoUrl && (
                    <div className="flex items-center space-x-2 text-sm text-blue-600">
                      <Download className="h-4 w-4" />
                      <span>Ready to download</span>
                    </div>
                  )}
                </div>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;

// ===================================

// src/components/CreateProject.js
import React, { useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { generateVideo } from '../services/mockApi';
import { Upload, Image, Mic, Wand2, ArrowRight, X, Check } from 'lucide-react';

const CreateProject = ({ setCurrentPage, setSelectedProject }) => {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    voiceoverText: '',
    animationStyle: 'cinematic',
    duration: 5
  });
  const [selectedFile, setSelectedFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const onDrop = React.useCallback((acceptedFiles) => {
    const file = acceptedFiles[0];
    if (file) {
      setSelectedFile(file);
      const reader = new FileReader();
      reader.onload = (e) => setPreview(e.target.result);
      reader.readAsDataURL(file);
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.gif', '.webp']
    },
    maxFiles: 1,
    maxSize: 10 * 1024 * 1024 // 10MB
  });

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!selectedFile) {
      setError('Please select an image file');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const project = await generateVideo(selectedFile, formData);
      setSelectedProject(project);
      setCurrentPage('project');
    } catch (error) {
      console.error('Error creating project:', error);
      setError('Failed to create project. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const removeFile = () => {
    setSelectedFile(null);
    setPreview(null);
  };

  const animationStyles = [
    { id: 'cinematic', name: 'Cinematic', description: 'Smooth camera movements and dramatic lighting' },
    { id: 'zoom', name: 'Zoom Effect', description: 'Dynamic zoom in/out with motion blur' },
    { id: 'parallax', name: 'Parallax', description: 'Depth-based movement for layered images' },
    { id: 'ambient', name: 'Ambient', description: 'Subtle atmospheric movement' }
  ];

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Create New Project</h1>
        <p className="text-gray-600">Transform your images into cinematic videos with AI</p>
      </div>

      {/* Progress Steps */}
      <div className="mb-8">
        <div className="flex items-center justify-between max-w-md mx-auto">
          {[1, 2, 3].map((stepNum) => (
            <div key={stepNum} className="flex items-center">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${
                step >= stepNum ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
              }`}>
                {step > stepNum ? <Check className="h-4 w-4" /> : stepNum}
              </div>
              {stepNum < 3 && (
                <div className={`w-16 h-1 ml-2 transition-all ${
                  step > stepNum ? 'bg-blue-600' : 'bg-gray-200'
                }`}></div>
              )}
            </div>
          ))}
        </div>
        <div className="flex justify-between mt-2 text-sm text-gray-600 max-w-md mx-auto">
          <span>Upload Image</span>
          <span>Configure</span>
          <span>Review</span>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Step 1: Upload Image */}
        {step === 1 && (
          <div className="bg-white rounded-xl shadow-sm border p-8 animate-fade-in">
            <h2 className="text-xl font-semibold mb-6">Upload Your Image</h2>
            
            {!selectedFile ? (
              <div {...getRootProps()} className={`border-2 border-dashed rounded-lg p-12 text-center transition-colors cursor-pointer ${
                isDragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'
              }`}>
                <input {...getInputProps()} />
                <Upload className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <p className="text-lg font-medium text-gray-900 mb-2">
                  {isDragActive ? 'Drop your image here' : 'Drag & drop an image here'}
                </p>
                <p className="text-gray-600 mb-4">or click to select a file</p>
                <div className="flex justify-center space-x-4 text-sm text-gray-500">
                  <span>JPEG, PNG, WebP</span>
                  <span>•</span>
                  <span>Max 10MB</span>
                </div>
              </div>
            ) : (
              <div className="relative max-w-md mx-auto">
                <img
                  src={preview}
                  alt="Preview"
                  className="w-full rounded-lg shadow-md"
                />
                <button
                  type="button"
                  onClick={removeFile}
                  className="absolute top-2 right-2 bg-red-500 text-white p-1 rounded-full hover:bg-red-600 transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
                <div className="mt-4 text-center">
                  <p className="text-sm text-gray-600">
                    {selectedFile.name} ({(selectedFile.size / (1024 * 1024)).toFixed(2)} MB)
                  </p>
                </div>
              </div>
            )}

            {selectedFile && (
              <div className="mt-8 flex justify-end">
                <button
                  type="button"
                  onClick={() => setStep(2)}
                  className="flex items-center space-x-2 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors"
                >
                  <span>Next</span>
                  <ArrowRight className="h-4 w-4" />
                </button>
              </div>
            )}
          </div>
        )}

        {/* Step 2: Configure */}
        {step === 2 && (
          <div className="bg-white rounded-xl shadow-sm border p-8 animate-fade-in">
            <h2 className="text-xl font-semibold mb-6">Configure Your Video</h2>
            
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Project Title
                </label>
                <input
                  type="text"
                  name="title"
                  value={formData.title}
                  onChange={handleInputChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Enter project title"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Description (Optional)
                </label>
                <textarea
                  name="description"
                  value={formData.description}
                  onChange={handleInputChange}
                  rows={3}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Describe your project"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Animation Style
                </label>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {animationStyles.map((style) => (
                    <div
                      key={style.id}
                      className={`p-4 border rounded-lg cursor-pointer transition-colors ${
                        formData.animationStyle === style.id
                          ? 'border-blue-500 bg-blue-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                      onClick={() => setFormData(prev => ({ ...prev, animationStyle: style.id }))}
                    >
                      <div className="flex items-center space-x-2 mb-2">
                        <input
                          type="radio"
                          name="animationStyle"
                          value={style.id}
                          checked={formData.animationStyle === style.id}
                          onChange={handleInputChange}
                          className="text-blue-600 focus:ring-blue-500"
                        />
                        <label className="font-medium text-gray-900">{style.name}</label>
                      </div>
                      <p className="text-sm text-gray-600">{style.description}</p>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Video Duration
                </label>
                <select
                  name="duration"
                  value={formData.duration}
                  onChange={handleInputChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value={3}>3 seconds</option>
                  <option value={5}>5 seconds</option>
                  <option value={10}>10 seconds</option>
                  <option value={15}>15 seconds</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  <div className="flex items-center space-x-2">
                    <Mic className="h-4 w-4" />
                    <span>Voiceover Text (Optional)</span>
                  </div>
                </label>
                <textarea
                  name="voiceoverText"
                  value={formData.voiceoverText}
                  onChange={handleInputChange}
                  rows={4}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Enter text for AI voiceover (optional)"
                />
                <p className="text-sm text-gray-500 mt-2">
                  Leave empty if you don't want voiceover
                </p>
              </div>
            </div>

            <div className="mt-8 flex justify-between">
              <button
                type="button"
                onClick={() => setStep(1)}
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Back
              </button>
              <button
                type="button"
                onClick={() => setStep(3)}
                className="flex items-center space-x-2 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors"
              >
                <span>Next</span>
                <ArrowRight className="h-4 w-4" />
              </button>
            </div>
          </div>
        )}

        {/* Step 3: Review & Create */}
        {step === 3 && (
          <div className="bg-white rounded-xl shadow-sm border p-8 animate-fade-in">
            <h2 className="text-xl font-semibold mb-6">Review Your Project</h2>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              <div>
                <h3 className="font-medium text-gray-900 mb-4">Preview</h3>
                <img
                  src={preview}
                  alt="Preview"
                  className="w-full rounded-lg shadow-md"
                />
              </div>
              
              <div>
                <h3 className="font-medium text-gray-900 mb-4">Project Details</h3>
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-600">Title</label>
                    <p className="text-gray-900">{formData.title || 'Untitled Project'}</p>
                  </div>
                  {formData.description && (
                    <div>
                      <label className="text-sm font-medium text-gray-600">Description</label>
                      <p className="text-gray-900">{formData.description}</p>
                    </div>
                  )}
                  <div>
                    <label className="text-sm font-medium text-gray-600">Animation Style</label>
                    <p className="text-gray-900 capitalize">{formData.animationStyle}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-600">Duration</label>
                    <p className="text-gray-900">{formData.duration} seconds</p>
                  </div>
                  {formData.voiceoverText && (
                    <div>
                      <label className="text-sm font-medium text-gray-600">Voiceover</label>
                      <p className="text-gray-900 italic">"{formData.voiceoverText}"</p>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {error && (
              <div className="mt-6 p-4 bg-red-50 border border-red-200 rounded-lg">
                <p className="text-red-600 text-sm">{error}</p>
              </div>
            )}

            <div className="mt-8 flex justify-between">
              <button
                type="button"
                onClick={() => setStep(2)}
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                disabled={loading}
              >
                Back
              </button>
              <button
                type="submit"
                disabled={loading}
                className="flex items-center space-x-2 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Creating...</span>
                  </>
                ) : (
                  <>
                    <Wand2 className="h-4 w-4" />
                    <span>Create Video</span>
                  </>
                )}
              </button>
            </div>
          </div>
        )}
      </form>
    </div>
  );
};

export default CreateProject;

// ===================================

// src/components/ProjectDetail.js
import React, { useState, useEffect } from 'react';
import { getProject, downloadVideo } from '../services/mockApi';
import { ArrowLeft, Download, Share2, CheckCircle, XCircle, RefreshCw, Play } from 'lucide-react';

const ProjectDetail = ({ project: initialProject, setCurrentPage }) => {
  const [project, setProject] = useState(initialProject);
  const [downloading, setDownloading] = useState(false);

  useEffect(() => {
    if (!project) return;

    // Listen for project updates
    const handleProjectUpdate = (event) => {
      if (event.detail.projectId === project.id) {
        const updatedProject = getProject(project.id);
        if (updatedProject) {
          setProject(updatedProject);
        }
      }
    };

    const handleProjectComplete = (event) => {
      if (event.detail.projectId === project.id) {
        const updatedProject = getProject(project.id);
        if (updatedProject) {
          setProject(updatedProject);
        }
      }
    };

    window.addEventListener('projectUpdate', handleProjectUpdate);
    window.addEventListener('projectComplete', handleProjectComplete);

    return () => {
      window.removeEventListener('projectUpdate', handleProjectUpdate);
      window.removeEventListener('projectComplete', handleProjectComplete);
    };
  }, [project]);

  const handleDownload = async () => {
    if (!project?.videoUrl) return;

    setDownloading(true);
    try {
      await downloadVideo(project.videoUrl, `${project.title || 'video'}.mp4`);
    } catch (error) {
      console.error('Download failed:', error);
      alert('Failed to download video. Please try again.');
    } finally {
      setDownloading(false);
    }
  };

  const handleShare = async () => {
    if (navigator.share && project?.videoUrl) {
      try {
        await navigator.share({
          title: project.title || 'AI Generated Video',
          text: 'Check out this AI-generated video!',
          url: window.location.href
        });
      } catch (error) {
        console.log('Share cancelled or failed:', error);
      }
    } else {
      navigator.clipboard.writeText(window.location.href).then(() => {
        alert('Project URL copied to clipboard!');
      });
    }
  };

  const getStatusInfo = (status) => {
    switch (status) {
      case 'processing':
        return {
          icon: <RefreshCw className="h-5 w-5 animate-spin" />,
          color: 'text-yellow-600',
          bgColor: 'bg-yellow-100',
          text: 'Processing'
        };
      case 'completed':
        return {
          icon: <CheckCircle className="h-5 w-5" />,
          color: 'text-green-600',
          bgColor: 'bg-green-100',
          text: 'Completed'
        };
      case 'failed':
        return {
          icon: <XCircle className="h-5 w-5" />,
          color: 'text-red-600',
          bgColor: 'bg-red-100',
          text: 'Failed'
        };
      default:
        return {
          icon: <RefreshCw className="h-5 w-5" />,
          color: 'text-gray-600',
          bgColor: 'bg-gray-100',
          text: 'Pending'
        };
    }
  };

  if (!project) {
    return (
      <div className="max-w-2xl mx-auto text-center">
        <div className="bg-red-50 border border-red-200 rounded-lg p-8">
          <XCircle className="h-12 w-12 text-red-600 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-red-900 mb-2">Project Not Found</h2>
          <p className="text-red-700 mb-4">The requested project could not be found.</p>
          <button
            onClick={() => setCurrentPage('dashboard')}
            className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
          >
            Go to Dashboard
          </button>
        </div>
      </div>
    );
  }

  const statusInfo = getStatusInfo(project.status);

  return (
    <div className="max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <button
          onClick={() => setCurrentPage('dashboard')}
          className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 transition-colors mb-4"
        >
          <ArrowLeft className="h-4 w-4" />
          <span>Back to Dashboard</span>
        </button>
        
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              {project.title || 'Untitled Project'}
            </h1>
            <div className={`inline-flex items-center space-x-2 px-3 py-1 rounded-full ${statusInfo.bgColor} ${statusInfo.color}`}>
              {statusInfo.icon}
              <span className="text-sm font-medium">{statusInfo.text}</span>
              {project.status === 'processing' && project.progress && (
                <span className="text-sm">({project.progress}%)</span>
              )}
            </div>
          </div>
          
          {project.status === 'completed' && project.videoUrl && (
            <div className="flex space-x-3 mt-4 sm:mt-0">
              <button
                onClick={handleShare}
                className="flex items-center space-x-2 bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors"
              >
                <Share2 className="h-4 w-4" />
                <span>Share</span>
              </button>
              <button
                onClick={handleDownload}
                disabled={downloading}
                className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
              >
                <Download className="h-4 w-4" />
                <span>{downloading ? 'Downloading...' : 'Download'}</span>
              </button>
            </div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
            {/* Video/Image Display */}
            <div className="aspect-video bg-gray-100 relative">
              {project.status === 'completed' && project.videoUrl ? (
                <video
                  controls
                  className="w-full h-full object-cover"
                  poster={project.imageUrl}
                >
                  <source src={project.videoUrl} type="video/mp4" />
                  Your browser does not support the video tag.
                </video>
              ) : (
                <div className="w-full h-full flex items-center justify-center relative">
                  {project.imageUrl && (
                    <img
                      src={project.imageUrl}
                      alt="Source"
                      className="w-full h-full object-cover"
                    />
                  )}
                  {project.status === 'processing' && (
                    <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                      <div className="text-center text-white">
                        <RefreshCw className="h-12 w-12 animate-spin mx-auto mb-4" />
                        <p className="text-lg font-medium">Processing your video...</p>
                        <p className="text-sm opacity-75">This may take a few minutes</p>
                        {project.progress && (
                          <div className="mt-4 w-64 mx-auto">
                            <div className="flex justify-between text-sm mb-1">
                              <span>Progress</span>
                              <span>{project.progress}%</span>
                            </div>
                            <div className="w-full bg-gray-600 rounded-full h-2">
                              <div 
                                className="bg-blue-500 h-2 rounded-full transition-all duration-300"
                                style={{ width: `${project.progress}%` }}
                              ></div>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                  {project.status === 'failed' && (
                    <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                      <div className="text-center text-white">
                        <XCircle className="h-12 w-12 mx-auto mb-4" />
                        <p className="text-lg font-medium">Processing failed</p>
                        <p className="text-sm opacity-75">
                          {project.error || 'Please try creating a new project'}
                        </p>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Description */}
            {project.description && (
              <div className="p-6 border-b">
                <h3 className="font-medium text-gray-900 mb-2">Description</h3>
                <p className="text-gray-700">{project.description}</p>
              </div>
            )}

            {/* Voiceover Text */}
            {project.voiceoverText && (
              <div className="p-6">
                <h3 className="font-medium text-gray-900 mb-2">Voiceover Script</h3>
                <p className="text-gray-700 italic">"{project.voiceoverText}"</p>
              </div>
            )}
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Project Info */}
          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Project Details</h3>
            <div className="space-y-3">
              <div>
                <label className="text-sm font-medium text-gray-600">Created</label>
                <p className="text-gray-900">
                  {new Date(project.createdAt).toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                  })}
                </p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-600">Animation Style</label>
                <p className="text-gray-900 capitalize">{project.animationStyle}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-600">Duration</label>
                <p className="text-gray-900">{project.duration} seconds</p>
              </div>
              {project.voiceoverText && (
                <div>
                  <label className="text-sm font-medium text-gray-600">Voiceover</label>
                  <p className="text-gray-900">Enabled</p>
                </div>
              )}
              {project.processingTime && (
                <div>
                  <label className="text-sm font-medium text-gray-600">Processing Time</label>
                  <p className="text-gray-900">{project.processingTime} seconds</p>
                </div>
              )}
            </div>
          </div>

          {/* Source Image */}
          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Source Image</h3>
            {project.imageUrl && (
              <img
                src={project.imageUrl}
                alt="Source"
                className="w-full rounded-lg shadow-sm"
              />
            )}
          </div>

          {/* Actions */}
          {project.status === 'completed' && (
            <div className="bg-white rounded-xl shadow-sm border p-6">
              <h3 className="font-semibold text-gray-900 mb-4">Actions</h3>
              <div className="space-y-3">
                <button
                  onClick={handleDownload}
                  disabled={downloading}
                  className="w-full flex items-center justify-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
                >
                  <Download className="h-4 w-4" />
                  <span>{downloading ? 'Downloading...' : 'Download Video'}</span>
                </button>
                <button
                  onClick={handleShare}
                  className="w-full flex items-center justify-center space-x-2 bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  <Share2 className="h-4 w-4" />
                  <span>Share Project</span>
                </button>
                {project.videoUrl && (
                  <a
                    href={project.videoUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-full flex items-center justify-center space-x-2 bg-green-100 text-green-700 px-4 py-2 rounded-lg hover:bg-green-200 transition-colors"
                  >
                    <Play className="h-4 w-4" />
                    <span>Open in New Tab</span>
                  </a>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ProjectDetail;// src/components/Navbar.js
import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Video, Menu, X, LogOut, User, Plus } from 'lucide-react';

const Navbar = ({ currentPage, setCurrentPage }) => {
  const { user, logout } = useAuth();
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const handleLogout = async () => {
    await logout();
    setCurrentPage('login');
  };

  if (!user) return null;

  return (
    <nav className="bg-white shadow-lg border-b">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <div 
            className="flex items-center space-x-2 cursor-pointer"
            onClick={() => setCurrentPage('dashboard')}
          >
            <Video className="h-8 w-8 text-blue-600" />
            <span className="text-xl font-bold text-gray-800">VideoAI</span>
          </div>

          <div className="hidden md:flex items-center space-x-6">
            <button 
              onClick={() => setCurrentPage('dashboard')}
              className={`transition-colors ${currentPage === 'dashboard' ? 'text-blue-600' : 'text-gray-700 hover:text-blue-600'}`}
            >
              Dashboard
            </button>
            <button 
              onClick={() => setCurrentPage('create')}
              className="flex items-center space-x-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
            >
              <Plus className="h-4 w-4" />
              <span>Create</span>
            </button>
            
            <div className="relative group">
              <button className="flex items-center space-x-2 text-gray-700 hover:text-blue-600 transition-colors">
                <User className="h-5 w-5" />
                <span>{user.displayName || user.email}</span>
              </button>
              
              <div className="absolute right-0 top-full mt-2 w-48 bg-white rounded-lg shadow-lg border opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all">
                <div className="py-2">
                  <div className="px-4 py-2 border-b">
                    <p className="text-sm font-medium text-gray-900">{user.displayName || 'User'}</p>
                    <p className="text-xs text-gray-500">{user.email}</p>
                  </div>
                  <button
                    onClick={handleLogout}
                    className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors flex items-center space-x-2"
                  >
                    <LogOut className="h-4 w-4" />
                    <span>Logout</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div className="md:hidden">
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="text-gray-700 hover:text-blue-600 transition-colors"
            >
              {isMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>

        {isMenuOpen && (
          <div className="md:hidden border-t bg-white">
            <div className="py-4 space-y-2">
              <button 
                onClick={() => { setCurrentPage('dashboard'); setIsMenuOpen(false); }}
                className="block w-full text-left px-4 py-2 text-gray-700 hover:bg-gray-50 transition-colors"
              >
                Dashboard
              </button>
              <button 
                onClick={() => { setCurrentPage('create'); setIsMenuOpen(false); }}
                className="block w-full text-left px-4 py-2 text-gray-700 hover:bg-gray-50 transition-colors"
              >
                Create Project
              </button>
              <div className="px-4 py-2 border-t">
                <p className="text-sm font-medium text-gray-900">{user.displayName || 'User'}</p>
                <p className="text-xs text-gray-500">{user.email}</p>
              </div>
              <button
                onClick={handleLogout}
                className="w-full text-left px-4 py-2 text-red-600 hover:bg-red-50 transition-colors flex items-center space-x-2"
              >
                <LogOut className="h-4 w-4" />
                <span>Logout</span>
              </button>
            </div>
          </div>
        )}
      </div>
    </nav>
  );
};

export default Navbar;

// ===================================

// src/components/Dashboard.js
import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { getProjects, getUserStats } from '../services/mockApi';
import { Plus, Video, Clock, Calendar, Zap, CheckCircle, XCircle, RefreshCw, Download } from 'lucide-react';

const Dashboard = ({ setCurrentPage, setSelectedProject }) => {
  const { user } = useAuth();
  const [projects, setProjects] = useState([]);
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
    
    // Listen for project updates
    const handleProjectUpdate = () => loadData();
    window.addEventListener('projectUpdate', handleProjectUpdate);
    window.addEventListener('projectComplete', handleProjectUpdate);
    
    return () => {
      window.removeEventListener('projectUpdate', handleProjectUpdate);
      window.removeEventListener('projectComplete', handleProjectUpdate);
    };
  }, []);

  const loadData = () => {
    const projectsData = getProjects();
    const statsData = getUserStats();
    setProjects(projectsData);
    setStats(statsData);
    setLoading(false);
  };

  const formatDate = (timestamp) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'completed': return 'bg-green-100 text-green-800';
      case 'processing': return 'bg-yellow-100 text-yellow-800';
      case 'failed': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'completed': return <CheckCircle className="h-4 w-4" />;
      case 'processing': return <RefreshCw className="h-4 w-4 animate-spin" />;
      case 'failed': return <XCircle className="h-4 w-4" />;
      default: return <Clock className="h-4 w-4" />;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Welcome back, {user?.displayName || user?.email}!
        </h1>
        <p className="text-gray-600">
          Create stunning videos from your images with AI-powered cinematic effects.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white rounded-xl shadow-sm border p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Credits Remaining</p>
              <p className="text-2xl font-bold text-blue-600">{stats.credits}</p>
            </div>
            <div className="h-12 w-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <Zap className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Projects</p>
              <p className="text-2xl font-bold text-gray-900">{stats.totalProjects}</p>
            </div>
            <div className="h-12 w-12 bg-green-100 rounded-lg flex items-center justify-center">
              <Video className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">This Month</p>
              <p className="text-2xl font-bold text-gray-900">{stats.thisMonth}</p>
            </div>
            <div className="h-12 w-12 bg-purple-100 rounded-lg flex items-center justify-center">
              <Calendar className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex flex-col sm:flex-row gap-4 mb-8">
        <button
          onClick={() => setCurrentPage('create')}
          className="flex items-center justify-center space-x-2 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors transform hover:scale-105"
        >
          <Plus className="h-5 w-5" />
          <span>Create New Project</span>
        </button>
        <button className="flex items-center justify-center space-x-2 bg-white border border-gray-300 text-gray-700 px-6 py-3 rounded-lg hover:bg-gray-50 transition-colors">
          <Zap className="h-5 w-5" />
          <span>Get More Credits</span>
        </button>
      </div>

      {/* Projects Grid */}
      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <div className="p-6 border-b">
          <h2 className="text-xl font-semibold text-gray-900">Your Projects</h2>
        </div>

        {projects.length === 0 ? (
          <div className="p-12 text-center">
            <Video className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No projects yet</h3>
            <p className="text-gray-600 mb-6">
              Create your first AI-powered video from an image to get started.
            </p>
            <button
              onClick={() => setCurrentPage('create')}
              className="inline-flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
            >
              <Plus className="h-4 w-4" />
              <span>Create Project</span>
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 p-6">
            {projects.map((project) => (
              <button
                key={project.id}
                onClick={() => {
                  setSelectedProject(project);
                  setCurrentPage('project');
                }}
                className="group block bg-gray-50 rounded-lg overflow-hidden hover:shadow-md transition-all transform hover:scale-105 text-left"
              >
                <div className="aspect-video bg-gray-200 relative">
                  <img
                    src={project.imageUrl}
                    alt={project.title}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-opacity flex items-center justify-center">
                    <Video className="h-8 w-8 text-white opacity-0 group-
