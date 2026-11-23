////////////////////////////////////////////////////////////////////////////////
//     These setups are part of the project: https://code.shin.company/php
//     Please respect the intellectual effort that went into creating them.
//     If you use or copy these ideas, proper credit would be appreciated.
//      - Author:  Mai Nhut Tan <shin@shin.company>
//      - License: https://code.shin.company/php/blob/main/LICENSE
////////////////////////////////////////////////////////////////////////////////

package dtp

import (
	"context"

	pb "github.com/moby/buildkit/frontend/gateway/pb"
	"google.golang.org/grpc"
)

// Methods that buildkit 0.28 added to LLBBridgeClient. They never read the Dockerfile, so they pass through.
func (proxy *dockerfileTransformingLLBProxy) ReadFileContainer(ctx context.Context, in *pb.ReadFileRequest, opts ...grpc.CallOption) (*pb.ReadFileResponse, error) {
	return proxy.client.ReadFileContainer(ctx, in, opts...)
}

func (proxy *dockerfileTransformingLLBProxy) ReadDirContainer(ctx context.Context, in *pb.ReadDirRequest, opts ...grpc.CallOption) (*pb.ReadDirResponse, error) {
	return proxy.client.ReadDirContainer(ctx, in, opts...)
}

func (proxy *dockerfileTransformingLLBProxy) StatFileContainer(ctx context.Context, in *pb.StatFileRequest, opts ...grpc.CallOption) (*pb.StatFileResponse, error) {
	return proxy.client.StatFileContainer(ctx, in, opts...)
}
